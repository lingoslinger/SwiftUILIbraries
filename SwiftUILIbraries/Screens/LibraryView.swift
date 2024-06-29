//
//  ContentView.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 6/29/24.
//

import SwiftUI

struct LibraryView: View {
    @Environment(LibraryDataSource.self) private var libraryDataSource
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(libraryDataSource.libraries) { library in
                    NavigationLink {
                        
                    } label: {
                        Text(library.name)
                    }
                }
            }
            .navigationTitle("Chicago Libraries")
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search by library name")
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
    LibraryView()
}
