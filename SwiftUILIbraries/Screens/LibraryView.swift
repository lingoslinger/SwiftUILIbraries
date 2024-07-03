//
//  ContentView.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 6/29/24.
//

import SwiftUI

struct LibraryView: View {
    @State private var showClosestLibraries = false
   
    var body: some View {
        NavigationStack {
            if showClosestLibraries {
                LibraryClosestView()
            } else {
                LibraryAlphaView()
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
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .environment(LibraryDataSource())
            .environment(LocationDataManager())
    }
}
