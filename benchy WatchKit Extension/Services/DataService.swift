//
//  DataService.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 20/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum ASSETTYPE: Int64 {
    case bench = 1
    case fountain = 2
    case toilet = 3
    case trash = 4
}

struct Asset {
    let id: UUID
    let lat: Double
    let lon: Double
    let createdAt: Date
    let assetType: ASSETTYPE
    let count: Int64
}

protocol SearchAssets {
    func getAssets(of type: ASSETTYPE, lat: Double, lon: Double, searchRadiusInKm: Double) -> [Asset]
}

protocol SaveData {
    func saveAsset(asset: Asset)
}

class DataService: SaveData, SearchAssets {
    
    //MARK: Variables and Constants
    
    static let singleton: DataService = DataService()
    
    
    // MARK: Private constructor for singleton and function to get single instance
    private init() {}
    
    static func getDataService() -> DataService {
        return singleton
    }
    
    //MARK: Coredata implementation to save data
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "coredata")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: Save and load function for Coredata
    
    func saveAsset(asset: Asset) {
        let coordinate = Coordinate(context: persistentContainer.viewContext)
        coordinate.assetType = asset.assetType.rawValue
        coordinate.count = asset.count
        coordinate.createdAt = asset.createdAt
        coordinate.id = asset.id
        coordinate.latitude = asset.lat
        coordinate.longitude = asset.lon
        saveContext()
//        print("data saved: " + String(asset.lat) + " " + String(asset.lon))
    }
    
    func updateAsset(asset: Asset) {
        let predicate = NSPredicate(format: "id = %@", asset.id as CVarArg)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")
        request.predicate = predicate
        
        do {
            let context = persistentContainer.viewContext
            let results = try context.fetch(request)
            let result = results[0] as! Coordinate
            
//            result.setValue(asset.id, forKey: "id")
//            result.setValue(asset.createdAt, forKey: "createdAt")
            result.setValue(asset.count, forKey: "count")
//            result.setValue(asset.assetType.rawValue, forKey: "assetType")
//            result.setValue(asset.lat, forKey: "latitude")
//            result.setValue(asset.lon, forKey: "longitude")
            
            saveContext()
        } catch {
            print(error)
        }

        print("data saved: " + String(asset.lat) + " " + String(asset.lon))
    }
    
    //MARK: Search Asset function
    
    func getAssets(of type: ASSETTYPE, lat: Double, lon: Double, searchRadiusInKm: Double) -> [Asset] {
        
        let radiusInLat = convertKmInLat(kilometers: searchRadiusInKm)
        let radiusInLon = convertKmInLon(kilometers: searchRadiusInKm)
        
        let maxLat = lat + radiusInLat
        let minLat = lat - radiusInLat
        let maxLon = lon + radiusInLon
        let minLon = lon - radiusInLon
        
        let predicate = NSPredicate(format: "latitude BETWEEN {%f,%f} AND longitude BETWEEN {%f,%f} AND assetType = %i", minLat, maxLat, minLon, maxLon, type.rawValue)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")
        request.predicate = predicate
        
        var foundAssets: [Asset] = []
        
        do {
            
            let results = try persistentContainer.viewContext.fetch(request)

            for r in results {
                if let result = r as? NSManagedObject {
                    guard let assetID = result.value(forKey: "id") as? UUID else {
                        return []
                    }
                    
                    guard let assetLat = result.value(forKey: "latitude") as? Double else {
                        return []
                    }
                    
                    guard let assetLon = result.value(forKey: "longitude") as? Double else {
                        return []
                    }
                    
                    guard let assetCreatedAt = result.value(forKey: "createdAt") as? Date else {
                        return []
                    }
                    
                    guard let assetCount = result.value(forKey: "count") as? Int64 else {
                        return []
                    }
                    
                    guard let assetTypeRawValue = result.value(forKey: "assetType") as? Int64 else {
                        return []
                    }
                    
                    var assetType = ASSETTYPE.bench
                    
                    switch assetTypeRawValue {
                    case ASSETTYPE.bench.rawValue:
                        assetType = ASSETTYPE.bench
                        break
                    case ASSETTYPE.fountain.rawValue:
                        assetType = ASSETTYPE.fountain
                        break
                    case ASSETTYPE.toilet.rawValue:
                        assetType = ASSETTYPE.toilet
                        break
                    case ASSETTYPE.trash.rawValue:
                        assetType = ASSETTYPE.trash
                        break
                    default:
                        assetType = ASSETTYPE.bench
                    }
                    
                    let fetchedAsset = Asset (
                        id: assetID,
                        lat: assetLat,
                        lon: assetLon,
                        createdAt: assetCreatedAt,
                        assetType: assetType,
                        count: assetCount
                    )
                    
                    foundAssets.append(fetchedAsset)
                }
            }
            
        } catch {
            print(error)
        }
        
        return foundAssets
    }
    
    //MARK: For development truncate database
    
    func truncateDatabase() {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")

        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)

        } catch {
            print(error)
        }

    }
    
    //MARK: Convertion of Kilometer in LON and LAT. See https://www.usgs.gov/faqs/how-much-distance-does-a-degree-minute-and-second-cover-your-maps?qt-news_science_products=0#qt-news_science_products for conversion
    
    private func convertKmInLat(kilometers: Double) -> Double {
        let conversionRateKmToLat = 0.009005358188
        return kilometers * conversionRateKmToLat
        
    }
    
    private func convertKmInLon(kilometers: Double) -> Double {
        let conversionRateKmToLon = 0.01138044839
        return kilometers * conversionRateKmToLon
    }
}
