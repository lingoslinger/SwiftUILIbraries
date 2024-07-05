//
//  LibraryClosestView.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 7/3/24.
//

import SwiftUI

struct LibraryClosestView: View {
    @Environment(LibraryDataSource.self) private var libraryDataSource
    @Environment(LocationDataManager.self) private var locationDataManager
    @State private var searchLocationText = ""
    
    var body: some View {
        if locationDataManager.isAuthorized {
            List {
                Section("10 Closest libraries by walking distance") {
                    ForEach(libraryDataSource.tenClosestLibraries) { library in
                        LibraryItemClosest(library: library)
                    }
                }
            }
            .task {
                do {
                    try await libraryDataSource.getTenClosestWalkingLibraries(from: locationDataManager.userLocation)
                } catch {
                    print(error)
                }
            }
        } else {
            List {
                Section("10 Closest libraries by walking distance") {
                    ForEach(libraryDataSource.tenClosestSearchLibraries) { library in
                        LibraryItemClosest(library: library)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LibraryClosestView()
            .environment(LibraryDataSource())
            .environment(LocationDataManager())
    }
}
