//
//  ContentView.swift
//  SwiftUILIbraries
//
//  Created by Allan Evans on 6/29/24.
//

import SwiftUI

struct LibraryNavView: View {
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
                let imageString = showClosestLibraries ? "text.justify" : "figure.walk"
                Button(action: {
                    showClosestLibraries.toggle()
                }) { Image(systemName: imageString) }
               
            }
        })
    }
}

#Preview {
    NavigationStack {
        LibraryNavView()
            .environment(LibraryDataSource())
            .environment(LocationDataManager())
    }
}
