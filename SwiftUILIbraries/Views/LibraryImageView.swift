//
//  LibraryImageView.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 4/12/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import SwiftUI

struct LibraryImageView: View {
    @Environment(LibraryDataSource.self) private var libraryDataSource
    @State private var libraryImageData: Data?
    let library: Library
    
    var loadingBackgroundColor: Color {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark ? Color.gray : Color.white
    }
    
    var body: some View {
        let imageHeight = UIScreen.main.bounds.width / 3.0 * 2.0
        VStack(alignment: .leading, spacing: 10) {
            if let data = libraryImageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: imageHeight, alignment: .center)
            } else {
                ZStack {
                    Rectangle()
                        .fill(loadingBackgroundColor)
                        .frame(height: imageHeight)
                        .onAppear {
                            Task {
                                do {
                                    self.libraryImageData = try await libraryDataSource.loadLibraryImageData(for: library)
                                } catch {
                                    print("Error loading library image...")
                                }
                            }
                        }
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(minHeight: imageHeight, alignment: .center)
                        .tint(UIScreen.main.traitCollection.userInterfaceStyle == .dark ? Color.white : Color.black)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LibraryImageView(library: previewLibrary)
            .environment(LibraryDataSource())
    }
    
}
