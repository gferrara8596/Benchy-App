//
//  LocationWarningView.swift
//  benchy WatchKit Extension
//
//  Created by Andrea Cascella on 23/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//

import SwiftUI


struct LocationWarningView: View {
    
    
    var body: some View {
        VStack{
            Image("SadCat").resizable().scaledToFit()
            Text("Benchy needs to determine your location to help you.")
                .font(.callout)
                .multilineTextAlignment(.center)
            }
    }
    
    
}

//struct LocationWarningView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationWarningView()
//    }
//}
