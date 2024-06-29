//
//  NewLibraryDataSource.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 6/29/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import Foundation
import Observation

@Observable
class LibraryDataSource {
    let webService: WebService
    
    var libraries: [Library] = []
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    func getLibraries() async throws {
        let resource = Resource(url: APIs.libraries.url, modelType: [Library].self)
        libraries = try await webService.load(resource)
    }
}
