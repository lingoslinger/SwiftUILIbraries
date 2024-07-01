//
//  LibraryImageView.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 4/12/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import SwiftUI
import SwiftSoup

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
                                    try await loadLibraryImageData()
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

extension LibraryImageView {
    private func loadLibraryImageData() async throws {
        let webService = WebService()
        
        let storedImageData = getStoredImageData(for: library)
        if storedImageData.count > 0 {
            libraryImageData = storedImageData
            return
        }

        var imageURLString = ""
        guard let libraryURLString = library.website?.url else { fatalError("No library URL")}
        let siteHTML = try await webService.getStringData(for: libraryURLString)
        let doc = try SwiftSoup.parse(siteHTML)
        let elements: Elements = try! doc.select("meta")
        for element in elements {
            if try element.attr("property") == "og:image" {
                imageURLString = try element.attr("content")
            }
        }
        
        let imageData = try await webService.getData(for: imageURLString)
        saveStoredImageData(imageData, for: library)
        libraryImageData = imageData
    }
    
}

extension LibraryImageView {
    func getStoredImageData(for library: Library) -> Data {
        guard let libEntity = libraryDataSource.libraryEntity(for: library) else { return Data() }
        return libEntity.photoData ?? Data()
    }
    
    func saveStoredImageData(_ imageData: Data, for library: Library) {
        guard let libEntity = libraryDataSource.libraryEntity(for: library) else { return }
        let context = CoreDataStack.shared.viewContext
        libEntity.photoData = imageData
        do {
            try context.save()
        } catch {
            print("Error saving image to Core Data: \(error.localizedDescription)")
        }
    }
}




#Preview {
    NavigationStack {
        LibraryImageView(library: previewLibrary)
            .environment(LibraryDataSource())
    }
    
}
