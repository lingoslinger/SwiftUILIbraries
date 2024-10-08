//
//  LibraryMapView.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 7/19/23.
//

import SwiftUI
import MapKit

struct LibraryMapView: View {
    let library: Library
    let mapLocation: CLLocationCoordinate2D
    
    @State private var mapPosition: MapCameraPosition
    
    init(library: Library) {
        self.library = library
        let lat = library.location?.lat ?? 0.0
        let lon = library.location?.lon ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapPosition = MapCameraPosition.region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500))
    }
    
    var body: some View {
        Map(position: $mapPosition) {
            Marker("\(library.name)", systemImage: "books.vertical.fill", coordinate: mapLocation)
        }.tint(.blue)
    }
}

#Preview {
    LibraryMapView(library: previewLibrary)
}

