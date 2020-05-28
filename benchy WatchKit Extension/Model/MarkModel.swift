//
//  MarkModel.swift
//  benchy WatchKit Extension
//
//  Created by Giuseppe Ferrara on 21/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

protocol MarkPosition {
    func markPosition(of type: ASSETTYPE)
    
}

class MarkModel: MarkPosition {
    private static let singleton = MarkModel()
    
    func markPosition(of type: ASSETTYPE) {
        let locationService = LocationService.getLocationService()
        let dataService = DataService.getDataService()
        if let location = locationService.getLocation() {
            let assets = dataService.getAssets(of: type, lat: location.coordinate.latitude , lon: location.coordinate.longitude, searchRadiusInKm: location.horizontalAccuracy/1000)
            if assets.isEmpty {
                let newAsset = Asset(
                    id: UUID(),
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude,
                    createdAt: Date(),
                    assetType: type,
                    count: 1)
                dataService.saveAsset(asset: newAsset)
            } else {
                let nearestAsset = locationService.getNearest(from: assets)
                let assetToSave = Asset(
                    id: nearestAsset.id,
                    lat: nearestAsset.lat,
                    lon: nearestAsset.lon,
                    createdAt: nearestAsset.createdAt,
                    assetType: nearestAsset.assetType,
                    count: nearestAsset.count + 1
                )
                dataService.updateAsset(asset: assetToSave)
            }
        }

    }
    
    private init() {
        
    }
    
    static func getMarkModel() -> MarkModel {
        return singleton
    }
    
}


