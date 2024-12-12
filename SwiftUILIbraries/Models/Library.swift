//
//  Library.swift
//  UniversalChiLibs
//
//  Created by Allan Evans on 11/2/23.
//  Copyright © 2023 AGE Software Consulting, LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct Library: Codable, Identifiable { //}, Hashable {
    let address : String?
    let city : String?
    let serviceHours : String?
    let location : Location?
    let branch : String
    let phone : String?
    let state : String?
    let website : Website?
    let zip : String?
    var walkingDistance: Double = 0.0
    var photoData: Data = Data()
    let id: Int = UUID().hashValue
    
    // using coding keys here because of some naming issues in the city's data source
    // I'm looking at you, "name_" 🤦‍♂️
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case city = "city"
        case serviceHours = "service_hours"
        case location = "location"
        case branch = "branch_"
        case phone = "phone"
        case state = "state"
        case website = "website"
        case zip = "zip"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        serviceHours = try values.decodeIfPresent(String.self, forKey: .serviceHours)
        location = try values.decodeIfPresent(Location.self, forKey: .location)
        branch = try values.decodeIfPresent(String.self, forKey: .branch) ?? ""
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        website = try values.decodeIfPresent(Website.self, forKey: .website)
        zip = try values.decodeIfPresent(String.self, forKey: .zip)
    }
    
    // need this for caching with Core Data
    init(address: String, city: String, serviceHours: String, location: Location, branch: String, phone: String, state: String, website: Website, zip: String, walkingDistance: Double, photoData: Data) {
        self.address = address
        self.city = city
        self.serviceHours = serviceHours
        self.location = location
        self.branch = branch
        self.phone = phone
        self.state = state
        self.website = website
        self.zip = zip
        self.walkingDistance = walkingDistance
        self.photoData = photoData
    }
}

struct Location: Codable {
    let latitude: String?
    let longitude: String?
    let needsRecoding: Bool?
    
    var lat: Double {
        // both the string and the Double we create from it are optional so 🤷‍♂️
        Double(latitude ?? "0.0") ?? 0.0
    }
    var lon: Double {
        Double(longitude ?? "0.0") ?? 0.0
    }
    
    var loc: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }
}

struct Website: Codable {
    let url: String?
}

extension Library {
    static func == (lhs: Library, rhs: Library) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
