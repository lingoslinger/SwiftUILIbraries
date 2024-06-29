//
//  PreviewData.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 7/19/23.
//

import Foundation

let previewLibraryData = """
[
    {"name_":"Albany Park",
"hours_of_operation":"Mon. & Wed., 10-6; Tues. & Thurs., Noon-8; Fri. & Sat., 9-5; Sun., 1-5",
"address":"3401 W. Foster Ave.",
"city":"Chicago",
"state":"IL",
"zip":"60625",
"phone":"(773) 539-5450",
"website":{"url":"https://www.chipublib.org/locations/3/"}, "location":{"latitude":"41.97557881655979","longitude":"-87.71361314512697"}}
    
]
"""
// since we can see the valid JSON above, it is "safe" to force unwrap optionals here
let decoder = JSONDecoder()
let previewData = previewLibraryData.data(using: .utf8)!
let previewLibraries = try! decoder.decode([Library].self, from: previewData)
let previewSectionTitles = ["A"]
let previewLibrary = previewLibraries.first!
