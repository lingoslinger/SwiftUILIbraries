//
//  SwiftUILIbrariesApp.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 6/29/24.
//

import SwiftUI

@main
struct SwiftUILIbrariesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LibraryView()
            }.environment(LibraryDataSource(webService: WebService()))
        }
    }
}
