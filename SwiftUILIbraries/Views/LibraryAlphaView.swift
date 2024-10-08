//
//  LibraryAlphaView.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 7/3/24.
//

import SwiftUI

struct LibraryAlphaView: View {
    @Environment(LibraryDataSource.self) private var libraryDataSource
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
        .overlay {
            if libraries.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
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
        LibraryAlphaView()
            .environment(LibraryDataSource())
    }
}
