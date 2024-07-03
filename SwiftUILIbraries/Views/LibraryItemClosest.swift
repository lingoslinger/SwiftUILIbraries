//
//  LibraryItemDistanceSorted.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 5/22/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import SwiftUI

struct LibraryItemClosest: View {
    let library: Library
    
    var metric: Bool {
        !(Locale.current.measurementSystem == .us || Locale.current.measurementSystem == .uk)
    }
    
    var formattedDistance: String {
        let divisor = (metric ? 1000.0 : 1609.344)
        let unit = (metric ? "km" : "mi")
        
        let dist = library.walkingDistance / divisor
        let formattedDistance = dist.formatted(
            .number
                .rounded(rule: .up, increment: 0.1))
        return "\(formattedDistance) \(unit)"
    }
    
    var body: some View {
        NavigationLink(destination: LibraryDetailView(library: library)) {
            Text("\(library.name)\n\(formattedDistance)")
        }
    }
}

#Preview {
    LibraryItemClosest(library: previewLibrary)
//        .environment(LibraryDataSource())
//        .environment(LocationDataManager())
}
