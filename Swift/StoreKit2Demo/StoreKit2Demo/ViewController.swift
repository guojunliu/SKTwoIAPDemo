//
//  ViewController.swift
//  StoreKit2Demo
//
//  Created by steve on 2023/4/20.
//

import UIKit
import StoreKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 创建列表
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 64 - 49))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        self.view.addSubview(tableView)
        
        // 读取商品列表
        let productIds:[String] = loadProductMaps();
        
        Task {
            
            // 向苹果服务端请求商品信息
            products = await SKTwoIAP().requestProducts(pids: productIds);
            
            // 更新列表
            tableView.reloadData()
        }
    }
    
    // 获取商品id
    func loadProductMaps () -> [String] {
        
        let productFileName = "Products"
        let productFileSuffix = "plist";

        guard let path = Bundle.main.path(forResource: productFileName, ofType: productFileSuffix) else {
            return []
        }
        
        guard let plist = FileManager.default.contents(atPath: path) else {
            return []
        }
        
        guard let data = try? PropertyListSerialization.propertyList(from: plist, format: nil) else {
            return []
        }
        
        guard let d = data as? [String] else {
            return []
        }
                
        return d
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        
        let product:Product = products[indexPath.row]
        cell.textLabel!.text = product.displayName
        cell.detailTextLabel?.text = product.displayPrice;
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Your purchase could not be verified by the App Store.")
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product:Product = products[indexPath.row]
        
        print("Will buy \(product.displayName)")
        
        // 创建透传参数
        var options:[String:String] = [:]
        options["appAccountToken"] = UUID().uuidString
        options["name"] = "steve"
        options["isWifi"] = "true"
        options["organic"] = "non-organic"
        
        Task {
            do {
                let tt = try await SKTwoIAP().purchase(product: product, options: options)
                if tt != nil {
                    print("\(product.displayName) purchase succeed")
                }
                else {
                    print("\(product.displayName) purchase failed")
                }
            } catch SKTwoIAPError.failedVerification {
                print("Your purchase could not be verified by the App Store.")
            } catch {
                print("\(product.displayName) purchase failed \(error)")
            }
        }

    }
    
}

