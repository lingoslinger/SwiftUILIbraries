//
//  MapUtilities.swift
//  SwiftLibraries
//
//  Created by Allan Evans on 1/20/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

func openAppleMaps(for library: Library) {
    // TODO: starting location
    // location permission given: use user location
    // no location permission: store search location as a StateObject in the search screen and use that
    
    let libLat = library.location?.lat ?? 0.0
    let libLon = library.location?.lon ?? 0.0
    let libLoc = CLLocation(latitude: libLat, longitude: libLon)
    
    var mapItems: [MKMapItem] = []
    
    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: libLoc.coordinate))
    mapItem.name = library.branch + " Library"
    
    mapItems.append(mapItem)
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
    MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
}
