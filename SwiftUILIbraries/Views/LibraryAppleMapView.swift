//
//  LibraryMapView.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 7/19/23.
//

import SwiftUI
import MapKit

struct LibraryAppleMapView: View {
    let library: Library
    let mapLocation: CLLocationCoordinate2D
    
    @State private var region: MKCoordinateRegion
    
    init(library: Library) {
        self.library = library
        let latString = library.location?.lat ?? 0.0
        let lonString = library.location?.lon ?? 0.0
        let latitude = Double(latString)
        let longitude = Double(lonString)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        _region = State(initialValue: MKCoordinateRegion(center: coordinate, span: span))
        mapLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [library]) { item in
            MapMarker(coordinate: mapLocation) // MapPin is deprecated in iOS 16
        }
    }
}

struct LibraryMapView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryAppleMapView(library: previewLibrary)
    }
}
