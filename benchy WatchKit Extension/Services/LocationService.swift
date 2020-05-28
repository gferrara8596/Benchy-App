//
//  LocationService.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 21/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import Foundation
import CoreLocation


class LocationService: NSObject {
    
    //MARK: Variables and constants
    
    static let singleton = LocationService()
    let locationManager = CLLocationManager()
    
    //MARK: Singleton function and constructor
    
    private override init() {
        super.init()
        locationManager.delegate = self as CLLocationManagerDelegate
    }
    
    static func getLocationService() -> LocationService {
        return singleton
    }
    
    //MARK: Functions
    
    func getLocation() ->CLLocation? {
        if isLocationAvailable() {
            return locationManager.location
        }
        return nil
        
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    
    func isLocationAvailable() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .denied :
            print("location denied")
            locationManager.requestWhenInUseAuthorization()
            return false
        case .notDetermined:
            print("location not determined")
            locationManager.requestWhenInUseAuthorization()
            return false
        case .restricted:
            print("location restricted")
            locationManager.requestWhenInUseAuthorization()
            return false
        case .authorizedAlways:
//            print("location always enabled")
            guard let safeLocation = locationManager.location else {return false}
            if safeLocation.horizontalAccuracy > 100.0 {
                print("accuracy is too low")
                return false
            }
             return true
        case .authorizedWhenInUse:
//            print("location in use enabled")
            guard let safeLocation = locationManager.location else {return false}
                   if safeLocation.horizontalAccuracy > 100.0 {
                       print("accuracy is too low")
                       return false
                   }
            return true
        @unknown default:
            print("location unknown")
            locationManager.requestWhenInUseAuthorization()
        }
        
        return false
    }
    
    func getNearest(from assets: [Asset]) -> Asset {
        let location = CLLocation()
        var sortableAssets: [SortableAsset] = []
        for asset in assets {
            let sortableAsset = SortableAsset(asset: asset,
                                              distance: location.distance(from: CLLocation(latitude: asset.lat, longitude: asset.lon)))
            sortableAssets.append(sortableAsset)
        }
        let sortedAssetsList = sortableAssets.sorted(by: {
            $0.distance < $1.distance
        })
        
        return sortedAssetsList[0].asset
    }
    
    struct SortableAsset {
        let asset: Asset
        let distance: Double
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if !((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locartions updated: \(locations)")
        CompassModel.getCompassModel().appendLocation(locations: locations)
    }
    
}
