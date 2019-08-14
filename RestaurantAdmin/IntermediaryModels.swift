//
//  IntermediaryModels.swift
//  RestaurantAdmin
//
//  Created by Muhammed Sahil on 09/06/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Foundation

struct Categories: Codable{
    let categories: [String]
}

struct AddNewItemHelper: Codable {
    var newMenuItem: MenuItem
}
