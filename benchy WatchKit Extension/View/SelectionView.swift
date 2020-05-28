//
//  SelectionView.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 20/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import SwiftUI

let imageNames = ["MenuButton1","MenuButton2","MenuButton3","MenuButton4"]
let locatonService = LocationService.getLocationService()


struct SelectionButton: View {
    
    
    
    
    var assetType: ASSETTYPE
    
    init(assetType: ASSETTYPE) {
        self.assetType = assetType
        
    }
    
    var body: some View {
        
        
       
        NavigationLink(destination: MarkSearchView(assetType: self.assetType)){
            Image(getImage(assetType: self.assetType))
            }.buttonStyle(PlainButtonStyle()).padding(10)
    }
        
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


struct SelectionView: View {
    
    
    
    @State private var locationCheck = locatonService.isLocationAvailable()

    
    var body: some View {
        
        VStack {
            HStack {
                SelectionButton(assetType: .fountain)
                SelectionButton(assetType: .bench)
            }
            HStack {
                SelectionButton(assetType: .trash)
                SelectionButton(assetType: .toilet)
            }
        }.onAppear().sheet(isPresented: $locationCheck, onDismiss: {
            print("location available: \(self.locationCheck)")
            self.locationCheck = locatonService.isLocationAvailable()
        }){
            LocationWarningView()
        }
    
    
   
}

struct SelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionView()
    }
}

}

    

