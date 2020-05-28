//
//  CompassModel.swift
//  benchy WatchKit Extension
//
//  Created by Giuseppe Ferrara on 22/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//


import WatchKit
import Foundation
import CoreLocation
import UIKit

class CompassModel {
    
    //MARK: Variables and constants
    
    private static let singleton = CompassModel()
    let locationService = LocationService.getLocationService()
    var locations: [CLLocation] = []
    
    //MARK: Private init for singleton
    
    private init() {
        locationService.startUpdatingLocation()
    }
    
    //MARK: GET function for CompassModel
    
    static func getCompassModel() -> CompassModel {
        return singleton
    }
    
    //MARK: Functions
    
    //get the degrees relativ e to true north of the location from the user current location
    func getCompassDegrees(for assetLocation: CLLocation) -> CLLocationDegrees? {
        let locationService = LocationService.getLocationService()
        if let userLocation = locationService.getLocation() {
           return getDegreesToNorth(from: userLocation, to: assetLocation)
            
        }
        
        return nil
    }
    
    func getDegreesToNorth(from startingLocation: CLLocation, to destinationLocation: CLLocation) -> CLLocationDegrees{
        let fromLat =  convertDegreesTo(radiant: startingLocation.coordinate.latitude)
        let fromLon =  convertDegreesTo(radiant: startingLocation.coordinate.longitude)
        let toLat =  convertDegreesTo(radiant: destinationLocation.coordinate.latitude)
        let toLon =  convertDegreesTo(radiant: destinationLocation.coordinate.longitude)
        
        let radiantToReturn =  atan2(sin(fromLon-toLon)*cos(toLat), cos(fromLat)*sin(toLat)-sin(fromLat)*cos(toLat)*cos(fromLon-toLon))
        
        return convertRadiansTo(degrees: radiantToReturn)
    }
    
    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }
    func stopUpdatingLocations() {
        locationService.stopUpdatingLocation()
    }
    
    func appendLocation(locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
        if locations.count > 10 {
            self.locations.removeFirst(locations.count - 5)
        }
    }
    
    func getDeviceDegreesToNorth() -> CLLocationDegrees? {
        if locations.count > 2 {
            let oldLocation = locations[locations.count-2]
            let lastLocation = locations[locations.count-1]
            
            
            return getDegreesToNorth(from: oldLocation, to: lastLocation)
        }
        
        return CLLocationDegrees.init()
     }
    
    
    func convertDegreesTo(radiant degrees: CLLocationDegrees) -> Double{
        return (degrees * .pi) / 180.0
    }
    
    func convertRadiansTo(degrees radiant: Double) -> CLLocationDegrees {
        return (radiant * 180.0) / .pi
    }
    
}

