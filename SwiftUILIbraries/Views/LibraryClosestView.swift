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
    
    var body: some View {
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
    }
}

#Preview {
    NavigationStack {
        LibraryClosestView()
            .environment(LibraryDataSource())
            .environment(LocationDataManager())
    }
}
