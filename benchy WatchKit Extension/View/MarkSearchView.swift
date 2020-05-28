//
//  MarkSearchView.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 20/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import SwiftUI

struct MarkSearchView: View {
    
    
    var assetType: ASSETTYPE
    let markModel = MarkModel.getMarkModel()
    let locatonService = LocationService.getLocationService()
    
    @State private var markedToggle = false
    
    
    
    var body: some View {
        
        
        VStack{
            
            
            Image(getImage(assetType: assetType)).scaledToFit()
            
            
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(getColor(assetType: assetType))
                    .frame(width: markedToggle ? 155 : 0, height: 40)
                
                
                
                
                Button(action: {
                    withAnimation(.spring()){
                        
                        self.markModel.markPosition(of: self.assetType)
                        self.locatonService.stopUpdatingLocation()
                        self.markedToggle.toggle()
                    }
                    
                }) {
                    Text(markedToggle ? "Marked" : "Mark")
                }.disabled(markedToggle)
                
            }
            
            if markedToggle == false {
                NavigationLink(destination: CompassView(assetType: self.assetType)){
                    Text("Search")
                }
                
                
                
                
            }
        }
    }
    
    init(assetType: ASSETTYPE){
        self.assetType = assetType
    }
    
    func getImage(assetType: ASSETTYPE) -> String{
        let imageNames = ["FountainButton","BenchButton","TrashButton","ToiletButton"]
        
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
    
    func getColor(assetType: ASSETTYPE) -> Color{
        
        var r: Double
        var g: Double
        var b: Double
        
        switch assetType{
        case .fountain:
            r = 0.39
            g = 0.77
            b = 0.95
        case .bench:
            r = 1.00
            g = 0.90
            b = 0.12
        case .trash:
            r = 0.95
            g = 0.57
            b = 0.10
        case .toilet:
            r = 0.27
            g = 0.53
            b = 0.78
        }
        
        return Color.init(red: r, green: g, blue: b)
    }
    
}

