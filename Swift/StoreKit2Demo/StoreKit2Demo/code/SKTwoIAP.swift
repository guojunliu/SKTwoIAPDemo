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

class SKTwoIAP: ObservableObject {
    
    init() {
        Task {
            
        }
    }
    
    // 从服务端请求商品信息
    
    func requestProducts(pids: [String]) async -> [Product] {
        do {
            let storeProducts = try await Product.products(for: pids)

            for product in storeProducts {
                switch product.type {
                case .consumable:   // 消耗品
                    print("Product id:\(product.id) description:\(product.description) type:\(product.type)")
                case .nonConsumable:    // 非消耗品
                    print("Product id:\(product.id) description:\(product.description) type:\(product.type)")
                case .autoRenewable:    // 自动续订订阅
                    print("Product id:\(product.id) description:\(product.description) type:\(product.type)")
                case .nonRenewable:     // 非续订订阅
                    print("Product id:\(product.id) description:\(product.description) type:\(product.type)")
                default:
                    //Ignore this product.
                    print("Unknown product")
                }
            }
            
            return storeProducts;
        }
        catch  {
            print("ssss");
            return [];
        }
    }
    
    // 购买商品
    func purchase(product: Product, options: [String: String]) async throws -> Transaction? {
        
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
        let result = try await product.purchase(options: productOptions)
        
        // 检查购买状态
        switch result {
        
        case .success(let verification):
            // 购买成功
            print("\(product.displayName)购买成功")
            
            // 检验单据
            let transaction = try localCheckVerified(result: verification)
            // 结束本次事务，完成购买
            await transaction.finish()

            return transaction
        
        case.userCancelled:
            // 用户取消
            print("用户取消\(product.displayName)购买")
            return nil
        
        case .pending:
            // 等待
            print("等待\(product.displayName)购买")
            return nil
            
        default:
            return nil
        }
    }
    
    // 本地校验单据
    func localCheckVerified<T> (result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // 验证jws失败
            throw SKTwoIAPError.failedVerification
        case .verified(let safe):
            // 验证jws成功
            return safe
        }
    }
}
