//
//  ContentView.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 6/29/24.
//

import SwiftUI

struct LibraryView: View {
    @Environment(LibraryDataSource.self) private var libraryDataSource
    @Environment(LocationDataManager.self) private var locationDataManager
    @State private var showClosestLibraries = false
    @State private var searchText = ""
    
    var libraries: [Library] {
        libraryDataSource.libraries.filter {
            searchText.count == 0 ? true : $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var sectionTitles: [String] {
        let firstLetters = libraries.map { $0.name.prefix(1) }
        return Array(Set(firstLetters)).map { String($0) }.sorted()
    }
    
    var body: some View {
        NavigationStack {
            if showClosestLibraries {
                
                List {
                    Section("10 Closest libraries by walking distance") {
                        ForEach(libraryDataSource.tenClosestLibraries) { library in
                            LibraryItemDistanceSorted(library: library)
                        }
                    }
                }
                .task {
//                    if locationDataManager.isAuthorized {
                        do {
                            try await libraryDataSource.getTenClosestWalkingLibraries(from: locationDataManager.userLocation)
                        } catch {
                            print(error)
                        }
//                    }
                }
            } else {
                List {
                    ForEach(sectionTitles, id: \.self) { sectionTitle in
                        Section(header: Text(sectionTitle)) {
                            let sectionLibraries = libraries.filter { $0.name.hasPrefix(sectionTitle) }.sorted { $0.name < $1.name }
                            ForEach(sectionLibraries) { library in
                                LibraryItemAlpha(library: library)
                            }
                        }
                    }
                }
                .searchable(text: $searchText,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: "Search by library name")
            }
        }
        .navigationTitle("Chicago Libraries")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                if showClosestLibraries {
                    Button(action: {
                        showClosestLibraries.toggle()
                    }) { Image(systemName: "text.justify") }
                } else {
                    Button(action: {
                        showClosestLibraries.toggle()
                    }) { Image(systemName: "figure.walk") }
                }
            }
        })
        .task {
            do {
                try await libraryDataSource.getLibraries()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .environment(LibraryDataSource())
            .environment(LocationDataManager())
    }
}
