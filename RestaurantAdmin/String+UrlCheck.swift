//
//  String+UrlCheck.swift
//  RestaurantAdmin
//
//  Created by Muhammed Sahil on 02/07/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Foundation
import Cocoa

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
