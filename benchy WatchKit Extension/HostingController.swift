//
//  HostingController.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 20/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import CoreLocation

class HostingController: WKHostingController<SelectionView> {
    override var body: SelectionView {
        loadAssetsFromCloud()
        return SelectionView()
    }
    
    func loadAssetsFromCloud(){
        
    }
    
    func testCode() {
        let demoFountain = CLLocation(latitude: 37.3305, longitude: -122.0296)
        let demoBench = CLLocation(latitude: 37.330, longitude: -122.0286)
        let dataService = DataService.getDataService()
        let markModel = MarkModel.getMarkModel()
        let locationService = LocationService.getLocationService()
        let location = locationService.getLocation()
        dataService.truncateDatabase()
        markModel.markPosition(of: .bench)
        let demoFountainAsset = Asset(id: UUID(),
                                      lat: demoFountain.coordinate.latitude,
                                      lon: demoFountain.coordinate.longitude,
                                      createdAt: Date(),
                                      assetType: .fountain,
                                      count: 1000000)
        let demoBenchAsset = Asset(id: UUID(),
        lat: demoBench.coordinate.latitude,
        lon: demoBench.coordinate.longitude,
        createdAt: Date(),
        assetType: .fountain,
        count: 1000000)
        dataService.saveAsset(asset: demoFountainAsset)
        dataService.saveAsset(asset: demoBenchAsset)
        let assets = dataService.getAssets(of: .fountain, lat: location!.coordinate.latitude, lon: location!.coordinate.longitude, searchRadiusInKm: 2)
        print(assets)
    }
}


