//
//  NavigationView.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 20/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import SwiftUI

struct CompassView: View {
    
    let locale = Locale.current
    
    
    
    let compassModel = CompassModel.getCompassModel()
    let locationService = LocationService.getLocationService()
    let dataService = DataService.getDataService()
    @State private var angleToRotate: Double = 0.0
    @State private var distanceToNearest: Double = 0.0
    var assetType: ASSETTYPE
    var assetIndex: Int = 0
    var assets: [Asset] = []
    var assetToFind: Asset?
    
    @State private var buttonString = "Find Nearest"
    
    
    var body: some View {
        
        VStack{
            Compass(assetType: assetType).rotationEffect(Angle(degrees: angleToRotate)).animation(.spring())
            Text(locale.usesMetricSystem ? "\(Int(distanceToNearest)) m" : "\(Int(distanceToNearest)) m")
            Button(action: {self.startFunction()}){
                Text(buttonString)
            }
            
        }
        
    }
    
    init(assetType: ASSETTYPE){
        self.assetType = assetType
        compassModel.startUpdatingLocation()
        setAssetToFind()
//        startUpdatingCompass()
    }
    
    mutating func setAssetToFind() {
        if let asset = self.getNearestAsset() {
            assetToFind = asset
        } else {
            print("no asset found")
        }
    }
    
    func startFunction(){
        buttonString = "Find Next"
        startUpdatingCompass()
        
    }
    
    func startUpdatingCompass(){
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            if self.assetToFind != nil {
                self.distanceToNearest = self.getDistanceToNearest(asset: self.assetToFind!)!
                print("distance:\(self.distanceToNearest)")
                self.angleToRotate = self.getDirectionToShow(asset: self.assetToFind!)
            } else {
                print("waiting for assets")
            }
            })
    }
    
    func getDirectionToShow(asset: Asset) -> CLLocationDegrees {
        let assetLocation = CLLocation(latitude: asset.lat, longitude: asset.lon)
        print("north: \(compassModel.getDeviceDegreesToNorth()!)")
        print("asset: \(compassModel.getCompassDegrees(for: assetLocation)!)")
        return compassModel.getDeviceDegreesToNorth()! - compassModel.getCompassDegrees(for: assetLocation)!
        
    }
    
//    mutating func updateAssetsInfo() {
//        if assets.isEmpty {
//            self.getNearestAssets()
//            self.popAsset()
//        }
//    }
    
    mutating func updateAngleToRotate(by degrees: Double) {
        self.angleToRotate = degrees
    }
    
    mutating func updateDistanceToNearest(distance: Double) {
        self.distanceToNearest = distance
    }
    
    
    mutating func getNearestAsset() -> Asset? {
        if let location = locationService.getLocation() {
            let assets = dataService.getAssets(of: assetType, lat: location.coordinate.latitude, lon: location.coordinate.longitude, searchRadiusInKm: 1)
            if !assets.isEmpty {
                return assets[assetIndex]
            }
            return nil
        }
        return nil
    }
    
//    mutating func searchNextAsset() {
//        assetIndex += 1
//        getNearestAssets()[assetIndex]
//    }
    
//    mutating func popAsset() {
//        assetToFind = assets.remove(at: 0)
//
//    }
    
    func getDistanceToNearest(asset: Asset) -> CLLocationDistance? {
        if let location = locationService.getLocation() {
            let assetLocation = CLLocation(latitude: asset.lat, longitude: asset.lon)
            let distance = round(location.distance(from: assetLocation))
            print("distanceOG: \(distance)")
            return distance
        }
        
        return nil
    }
    
    
    
    
    
}

struct Compass: View{
    var assetType: ASSETTYPE
    
    init(assetType: ASSETTYPE){
        self.assetType = assetType
    }
    
    var body: some View{
        
        Image(getImage(assetType: assetType))
    }
    
    func getImage(assetType: ASSETTYPE) -> String{
        let imageNames = ["FountainCompass","BenchCompass","TrashCompass","ToiletCompass"]
        
        switch assetType {
        case .fountain:
            return imageNames[0]
        case .bench:
            return imageNames[1]
        case .trash:
            return imageNames[2]
        case .toilet:
            return imageNames[3]
        }
    }
}


//
//struct CompassView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompassView(assetType: )
//    }
//}
