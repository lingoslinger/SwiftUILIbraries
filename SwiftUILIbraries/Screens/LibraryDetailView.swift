//
//  LibraryDetailView.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 7/19/23.
//

import SwiftUI

struct LibraryDetailView: View {
    let library: Library

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
//                    LibraryImageView(library: library)
                    Text(library.address ?? "Address not available")
                        .padding(.leading, 10)
                    LibraryPhoneNumberView(library: library)
                        .padding(.leading, 10)
                    Text(library.hoursOfOperation?.formattedHours ?? "Hours not available")
                        .padding(.leading, 10)
                   
                    LibraryAppleMapView(library: library)
                        .frame(height: 200, alignment: .top)
                        .onTapGesture {
                            
                            // openAppleMaps(for: library, startLoc: locationDataManager.userLocation)
                        }
                        .gesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .onChanged { _ in
                                    print("Long press detected, do what you will with it")
                                }
                        )
                        .padding(.bottom, 10)
                       
                   
                }
                .padding(.bottom, 10)
            }
        }
        .navigationTitle(library.name)
    }
}

struct LibraryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryDetailView(library: previewLibrary)
    }
}
