//
//  MenuController.swift
//  RestaurantAdmin
//
//  Created by Muhammed Sahil on 09/06/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Foundation
import Cocoa

class MenuController {
    static let shared = MenuController()
    
    /// URL for running on an iOS device on my WiFi network
    let baseURL = URL(string: "http://home-macbook-pro.local:8080/")!
    
    /// URL for running on the simulator
    //let baseURL = URL(string:"http://localhost:8080/")!
    
    // uncomment the url you want to use and comment out the other one. While using the local network url, please use your computers network name in place of home-macbook-pro . It can be found under system preferences -> Sharing -> below the Computer Name textField.
    
    //
    func fetchCategories(completion: @escaping ([String]?) -> Void) {
        //let categoryURL = URL(string: "http://home-macbook-pro.local:8080/categories")!
        let categoryURL = baseURL.appendingPathComponent("categories")
        
        let task = URLSession.shared.dataTask(with: categoryURL) { (data, urlResponse, error) in
            if let data = data, let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let categories = jsonDictionary["categories"] as? [String] {
                completion(categories)
            } else {
                print("Categories fetch failed --MenuController.swift-")
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    //
    func fetchMenuItems(categoryName: String, completion: @escaping ([MenuItem]?) -> Void) {
        // <Ignore>
        //        let initialMenuURL = baseURL.appendingPathComponent("menu")
        //        var components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        //        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        //
        //        let menuURL = components.url!
        // </Ignore> (only if url requires query items)
        
        //let menuURL = URL(string: "http://home-macbook-pro.local:8080/menu/\(categoryName)")!
        let AllMenuURL = baseURL.appendingPathComponent("menu")
        let menuURL = AllMenuURL.appendingPathComponent(categoryName)
        
        let task = URLSession.shared.dataTask(with: menuURL) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                
                completion(menuItems.items)
            } else {
                print("Menu Items fetch failed --MenuController.swift-")
                completion(nil)
            }
        }
        task.resume()
    }
    
    //
    func fetchAllItems(completion: @escaping ([MenuItem]?) -> Void) {
        //let menuURL = URL(string: "http://localhost:8080/menu")!
        let AllMenuURL = baseURL.appendingPathComponent("menu")
        
        let task = URLSession.shared.dataTask(with: AllMenuURL) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                completion(menuItems.items)
            } else {
                print("All Menu Items fetch failed --MenuController.swift-")
                completion(nil)
            }
        }
        task.resume()
    }
    
    //
    func deleteMenuItem(id: Int, completion: @escaping (String?) -> Void) {
        //let deleteURL = URL(string: "http://localhost:8080/admin/delete/\(id)")!
        let deleteURL = baseURL.appendingPathComponent("admin/delete/\(id)")
        
        let task = URLSession.shared.dataTask(with: deleteURL) { (data, urlResponse, error) in
            if let data = data, let stringVal = String(data: data, encoding: .utf8) {
                completion(stringVal)
            } else {
                print("Delete Menu Item failed -- Menucontroller.swift")
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    //
    func submitMenuItem(_ menuItem: MenuItem, completion: @escaping (MenuItem?) -> Void) {
        //let submitURL = URL(string: "http://localhost:8080/admin/add")!
        let submitURL = baseURL.appendingPathComponent("admin/add")
        
        var request = URLRequest(url: submitURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: MenuItem] = ["newMenuItem": menuItem]
        let jsonData = try? JSONEncoder().encode(data)
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let newItem = try? JSONDecoder().decode(AddNewItemHelper.self, from: data) {
                completion(newItem.newMenuItem)
            } else {
                print("Submit Menu Item Failed --MenuController.swift")
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    //
    func fetchImage(url: URL, completion: @escaping (NSImage?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            if let data = data, let image = NSImage(data: data) {
                completion(image)
            }else {
                print("Could not fetch image --MenuController.swift-")
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    
}
