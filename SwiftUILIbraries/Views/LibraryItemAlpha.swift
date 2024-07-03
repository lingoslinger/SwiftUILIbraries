//
//  LibraryItemAlpha.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 5/22/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import SwiftUI

struct LibraryItemAlpha: View {
    let library: Library
    
    var body: some View {
        NavigationLink(destination: LibraryDetailView(library: library)) {
            Text(library.name)
        }
    }
}

#Preview {
    LibraryItemAlpha(library: previewLibrary)
//        .environment(LibraryDataSource())
//        .environment(LocationDataManager())
}
