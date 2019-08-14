//
//  MenuItem.swift
//  RestaurantAdmin
//
//  Created by Muhammed Sahil on 09/06/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Foundation

struct MenuItem: Codable {
    var id: Int?
    var name: String
    var description: String
    var price: Double
    var category: String
    var imageURL: URL
    var preparationTime: Int
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case description
        case price
        case category
        case imageURL //= "image_url" // not required when using vapor server
        case preparationTime
    }
    
}

struct MenuItems: Codable {
    let items: [MenuItem]
}

