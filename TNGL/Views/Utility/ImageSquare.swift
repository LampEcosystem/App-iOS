//
//  ImageSquare.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/12/22.
//

import SwiftUI

struct ImageSquare: View {
    var fillColor: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(fillColor)
                .shadow(radius: 2.0)
                .frame(width: 50, height: 50)
                .padding()

            Image(systemName: imageName)
                .imageScale(.large)
                .foregroundColor(.white)
                .shadow(radius: 2.0)
        }
    }
}

struct ImageSquare_Previews: PreviewProvider {
    static var previews: some View {
        ImageSquare(fillColor: Color.red, imageName: "lightbulb")
    }
}
