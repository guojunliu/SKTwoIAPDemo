//
//  SKTwoIAP.swift
//  StoreKit2Demo
//
//  Created by steve on 2023/4/20.
//

import Foundation
import StoreKit

public enum SKTwoIAPError: Error {
    case failedVerification
}

public enum SKTProductType {
    // 未知
    case unknown
    // 消耗品
    case consumable
    // 非消耗品
    case nonConsumable
    // 非续订订阅
    case nonRenewable
    // 自动续订订阅
    case autoRenewable
}

// StoreKit2的Product的oc对象
@objcMembers public class SKTProduct: NSObject {
    
    public let id: String
    public let type: SKTProductType
    public let jsonRepresentation: Data
    public let displayName: String
    public let productDescription: String
    public let price: Decimal
    public let displayPrice: String
    public let isFamilyShareable: Bool
    
    init (id pid:String,
          type t:SKTProductType,
    jsonRepresentation pJsonRepresentation: Data,
    displayName pDisplayName: String,
    productDescription pDescription: String,
    price pPrice: Decimal,
    displayPrice pDisplayPrice: String,
    isFamilyShareable pIsFamilyShareable: Bool
    ) {
        id = pid
        type = t
        jsonRepresentation = pJsonRepresentation
        displayName = pDisplayName
        productDescription = pDescription
        price = pPrice
        displayPrice = pDisplayPrice
        isFamilyShareable = pIsFamilyShareable
    }
    
    convenience init (product:Product) {
        
        var t: SKTProductType
        switch product.type {
        case .consumable:
            t = SKTProductType.consumable
        case .nonConsumable:
            t = SKTProductType.nonConsumable
        case .autoRenewable:
            t = SKTProductType.autoRenewable
        case .nonRenewable:
            t = SKTProductType.nonRenewable
        default:
            t = SKTProductType.unknown
        }
        
        self.init(id: product.id, type: t, jsonRepresentation: product.jsonRepresentation, displayName: product.displayName, productDescription: product.description, price: product.price, displayPrice: product.displayPrice, isFamilyShareable: product.isFamilyShareable)
    }
}

// StoreKit2的Transaction的oc对象
@objcMembers public class SKTTransaction: NSObject {

        public let id: UInt64
        public let originalID: UInt64
        public var jsonRepresentation: Data
        public let productID: String
        public let appBundleID: String
        public let appAccountToken: UUID?
        public let signedDate: Date
    
    init (id tid:UInt64,
          originalID tOriginalID:UInt64,
          jsonRepresentation tJsonRepresentation: Data,
          productID tProductID: String,
          appBundleID tAppBundleID: String,
          appAccountToken tAppAccountToken: UUID?,
          signedDate tSignedDate: Date
    ) {
        id = tid
        originalID = tOriginalID
        jsonRepresentation = tJsonRepresentation
        productID = tProductID
        appBundleID = tAppBundleID
        appAccountToken = tAppAccountToken
        signedDate = tSignedDate
    }
    
    convenience init (transaction:Transaction) {
        
        self.init(id: transaction.id, originalID: transaction.originalID, jsonRepresentation: transaction.jsonRepresentation, productID: transaction.productID, appBundleID: transaction.appBundleID, appAccountToken: transaction.appAccountToken, signedDate: transaction.signedDate)
    }
}

// StoreKit2 的事务类
@objcMembers public class SKTwoIAP: NSObject {
    
    var productMap:[String:Product] = [:]
    var sktProductMap:[String:SKTProduct] = [:]
    
    @objc static let sharedInstance = SKTwoIAP()
    
    // 从服务端请求商品列表信息
    @objc func requestProducts(pids: [String]) async -> [SKTProduct] {
        do {
            let storeProducts = try await Product.products(for: pids)
            var currentSKTProducts:[SKTProduct] = [];
            
            for product in storeProducts {
                
                let sktProduct = SKTProduct(product: product)
                currentSKTProducts.append(sktProduct)
                
                productMap[product.id] = product
                sktProductMap[product.id] = sktProduct
            }
            return currentSKTProducts;
        }
        catch  {
            return [];
        }
    }
    
    // 从服务端请求单个商品信息
    @objc func requestProduct(pid: String) async -> SKTProduct? {
        do {
            let storeProducts = try await Product.products(for: [pid])
            
            guard let product = storeProducts.first else {
                return nil
            }
            productMap[product.id] = product
            
            let sktProduct = SKTProduct(product: product)
            return sktProduct;
        }
        catch  {
            return nil;
        }
    }
    
    // 购买商品(根据id)
    @objc func purchase(productId: String, options: [String: String]) async throws -> SKTTransaction? {
        
        guard let product = productMap[productId] else {
            return nil
        }
        
        return try await self.purchase(product: product, options: options)
    }
    
    // 购买商品(根据SKTProduct)
    @objc func purchase(product p: SKTProduct, options: [String: String]) async throws -> SKTTransaction? {
        
        guard let product = productMap[p.id] else {
            return nil
        }
        
        return try await self.purchase(product: product, options: options)
    }
    
    // 购买商品
    func purchase(product: Product, options: [String: String]) async throws -> SKTTransaction? {
        
        // 组装 Options
        var productOptions: Set<Product.PurchaseOption> = []
        for key in options.keys {
            guard let value = options[key] else { break }
            if key == "appAccountToken" {
                // appAccountToken 采用特殊方法设置
                guard let uuid = UUID(uuidString: value) else {
                    break
                }
                let productOption = Product.PurchaseOption.appAccountToken(uuid)
                productOptions.insert(productOption)
            }
            else {
                let productOption = Product.PurchaseOption.custom(key: key, value: value)
                productOptions.insert(productOption)
            }
        }
        
        // 开始购买
        let result:Product.PurchaseResult = try await product.purchase(options: productOptions)
        
        // 检查购买状态
        switch result {
        
        case .success(let verification):
            // verification is VerificationResult<Transaction>
            // 购买成功
            print("\(product.displayName)购买成功")
            
            // 检验单据
            let transaction:Transaction = try localCheckVerified(result: verification)
            
            let jwsRepresentation = verification.jwsRepresentation;
            print("jwsRepresentation is \(jwsRepresentation)")
            
            // 结束本次事务，完成购买
            await transaction.finish()

            // TODO 需要把transaction成map，oc不支持Transaction
            var sktTransaction:SKTTransaction = SKTTransaction(transaction: transaction);
            return sktTransaction
        
        case.userCancelled:
            // 用户取消
            return nil
        
        case .pending:
            // 等待
            return nil
            
        default:
            return nil
        }
    }
    
    // 本地校验单据
    func localCheckVerified<T> (result: VerificationResult<T>) throws -> T {
        // T is Transaction
        switch result {
        case .unverified:
            // 验证jws失败
            throw SKTwoIAPError.failedVerification
        case .verified(let transaction):
            // 验证jws成功
            return transaction
        }
    }
    
    @objc static func canMakePayments () -> Bool {
        return AppStore.canMakePayments
    }
}
