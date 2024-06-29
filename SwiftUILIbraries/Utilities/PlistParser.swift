//
//  PlistParser.swift
//  SwiftLibraries
//
//  Created by Allan Evans on 11/4/23.
//  Copyright © 2023 AGE Software Consulting, LLC. All rights reserved.
//

import Foundation

func plistToDictionary(fromFile file: String, ofType type: String) -> [String: Any]? {
    if let path = Bundle.main.path(forResource: file, ofType: type),
       let xml = FileManager.default.contents(atPath: path) {
        do {
            if let dictionary = try PropertyListSerialization.propertyList(from: xml, format: nil) as? [String: Any] {
                return dictionary
            }
        } catch {
            print("Error converting plist to dictionary: \(error)")
        }
    }
    return nil
}
