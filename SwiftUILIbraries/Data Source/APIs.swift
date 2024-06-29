//
//  APIs.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 6/29/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import Foundation

enum APIs {
    case libraries
    
    private var baseURL: URL {
        guard let pListDict = plistToDictionary(fromFile: "Webservice", ofType: "plist") else {
            fatalError("prod_url not found in WebService.plist")
        }
        guard let baseURLString = pListDict["prod_url"] as? String else {
            fatalError("no prod_url entry in Webservice.plist")
        }
        return URL(string: baseURLString)! // pretty sure this is a string, if it is not we have problems
    }
    
    var url: URL {
        // this is where we can append path components in a more involved API
        // for libraries all we need is the base URL
        switch self {
            case .libraries:
                baseURL
        }
    }
}
