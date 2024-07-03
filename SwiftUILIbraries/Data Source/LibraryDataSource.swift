//
//  LibraryDataSource.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 6/29/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import Foundation
import CoreData
import SwiftSoup
import CoreLocation
import MapKit

@Observable
class LibraryDataSource {
    private let webService: WebService = WebService()
    private let coreDataStack = CoreDataStack.shared
    
    private var cacheExpired: Bool {
        let cacheLastSaved = UserDefaults.standard.double(forKey: "CacheDate")
        if cacheLastSaved == 0 { return true } // for case when cache has not been saved yet
        let today = Date().timeIntervalSince1970
        let cacheTimeInterval =  24.0 * 60.0 * 60.0 // one day for now, eventually a settable preference
        return (today - cacheLastSaved > cacheTimeInterval)
    }
    
    var libraries: [Library] = []
    var tenClosestLibraries: [Library] = []
    
    func getLibraries() async throws {
        if cacheExpired{ deleteAllLibraries() }
        let cachedLibraries = try loadCachedLibraries()
        if !cachedLibraries.isEmpty {
            libraries = cachedLibraries.map { mapEntityToModel($0) }
        } else {
            let resource = Resource(url: APIs.libraries.url, modelType: [Library].self)
            libraries = try await webService.load(resource)
            let timeInterval: Double = Date().timeIntervalSince1970
            UserDefaults.standard.set(timeInterval, forKey: "CacheDate")
            await saveToCoreData(libraries)
        }
    }
    
    private func loadCachedLibraries() throws -> [LibraryEntity] {
        let request: NSFetchRequest<LibraryEntity> = LibraryEntity.fetchRequest()
        return try coreDataStack.viewContext.fetch(request)
    }
    
    private func saveToCoreData(_ libraries: [Library]) async {
        let context = coreDataStack.viewContext
        await context.perform {
            for library in libraries {
                let libraryEntity = LibraryEntity(context: context)
                self.mapModelToEntity(from: library, to:libraryEntity)
            }
            do {
                try context.save()
            } catch {
                print("Error saving to Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteAllLibraries() {
        let context = coreDataStack.viewContext
        guard let entities = context.persistentStoreCoordinator?.managedObjectModel.entities else { return }
        for entity in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            do {
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(batchDeleteRequest)
                context.reset()
            } catch {
                print("Error deleting \(String(describing: entity.name)), \(error.localizedDescription)")
            }
        }
        do {
            try context.save()
        } catch {
            print("Error saving context after deletion, \(error.localizedDescription)")
        }
    }
    
    private func mapModelToEntity(from library: Library, to libraryEntity: LibraryEntity) {
        libraryEntity.address = library.address
        libraryEntity.city = library.city
        libraryEntity.hoursOfOperation = library.hoursOfOperation
        libraryEntity.location = locationToEntity(library.location ?? Location(latitude: "0.0", longitude: "0.0", needsRecoding: false))
        libraryEntity.name = library.name
        libraryEntity.phone = library.phone
        libraryEntity.state = library.state
        libraryEntity.website = websiteToEntity(library.website ?? Website(url: ""))
        libraryEntity.zip = library.zip
        libraryEntity.walkingDistance = library.walkingDistance
        libraryEntity.photoData = library.photoData
    }
    
    private func locationToEntity(_ location: Location) -> LocationEntity {
        let locationEntity = LocationEntity(context: coreDataStack.viewContext)
        locationEntity.lat = location.lat
        locationEntity.lon = location.lon
        locationEntity.needsRecoding = location.needsRecoding ?? false
        return locationEntity
    }
    
    private func websiteToEntity(_ website: Website) -> WebsiteEntity {
        let websiteEntity = WebsiteEntity(context: coreDataStack.viewContext)
        websiteEntity.url = website.url
        return websiteEntity
    }
    
    private func mapEntityToModel(_ libraryEntity: LibraryEntity) -> Library {
        return Library(address: libraryEntity.address ?? "",
                       city: libraryEntity.city ?? "",
                       hoursOfOperation: libraryEntity.hoursOfOperation ?? "",
                       location: locationFromEntity(libraryEntity),
                       name: libraryEntity.name ?? "",
                       phone: libraryEntity.phone ?? "",
                       state: libraryEntity.state ?? "",
                       website: websiteFromEntity(libraryEntity),
                       zip: libraryEntity.zip ?? "",
                       walkingDistance: libraryEntity.walkingDistance,
                       photoData: libraryEntity.photoData ?? Data())
    }
    
    private func locationFromEntity(_ libraryEntity: LibraryEntity) -> Location {
        let latString = String(libraryEntity.location?.lat ?? 0.0)
        let lonString = String(libraryEntity.location?.lon ?? 0.0)
        let needsRecoding = libraryEntity.location?.needsRecoding
        return Location(latitude: latString, longitude: lonString, needsRecoding: needsRecoding)
    }
    
    private func websiteFromEntity(_ libraryEntity: LibraryEntity) -> Website {
        return Website(url: libraryEntity.website?.url)
    }
    
    private func libraryEntity(for library: Library) -> LibraryEntity? {
        let context = CoreDataStack.shared.viewContext
        let request: NSFetchRequest<LibraryEntity> = LibraryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", library.name)
        let results = try? context.fetch(request)
        return results?.first
    }
}

extension LibraryDataSource {
    func loadLibraryImageData(for library: Library) async throws -> Data {
        let storedImageData = getStoredImageData(for: library)
        if storedImageData.count > 0 {
            return storedImageData
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
        return imageData
    }
    
    private func getStoredImageData(for library: Library) -> Data {
        guard let libEntity = libraryEntity(for: library) else { return Data() }
        return libEntity.photoData ?? Data()
    }
    
    private func saveStoredImageData(_ imageData: Data, for library: Library) {
        guard let libEntity = libraryEntity(for: library) else { return }
        let context = CoreDataStack.shared.viewContext
        libEntity.photoData = imageData
        do {
            try context.save()
        } catch {
            print("Error saving image to Core Data: \(error.localizedDescription)")
        }
    }
}

extension LibraryDataSource {
    func getTenClosestWalkingLibraries(from location: CLLocation) async throws {
        // step 1: sort libraries by "as the crow flies" distance
        let sortedLibs: [Library] = libraries.sorted {
            guard let loc1 = $0.location?.loc, let loc2 = $1.location?.loc else { return true }
            return location.distance(from: loc1) < location.distance(from: loc2)}
        // step 2: get the top ten and get their walking distances
        let firstTen = Array(sortedLibs.prefix(10))
        var newLibs: [Library] = []
        let taskResults: ()? = try? await withThrowingTaskGroup(of: Library.self) { group in
            for library in firstTen {
                guard let libLoc = library.location?.loc else { return }
                group.addTask {
                    var newLib = library
                    let route = await self.walkingDistance(from: location, to: libLoc)
                    newLib.walkingDistance = route?.distance ?? 0.0
//                    print("library \(newLib.name), walking distance is \(newLib.walkingDistance) meters")
                    return newLib
                }
            }
            for try await result in group {
                newLibs.append(result)
            }
            
            //return results
        }
        // step 3: update the (published) variable so the UI will update
        tenClosestLibraries = newLibs.sorted {
            $0.walkingDistance < $1.walkingDistance
        }
        print(tenClosestLibraries)
    }
    
    func clearSortedLibraries() {
        tenClosestLibraries = []
    }
        
    private func walkingDistance(from: CLLocation, to: CLLocation) async -> MKRoute? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to.coordinate))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            return response.routes.first
        } catch {
            print("Error calculating route: \(error.localizedDescription)")
            return nil
        }
    }
}
