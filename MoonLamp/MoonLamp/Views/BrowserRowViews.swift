//
//  BrowserRowViews.swift
//  MoonLamp
//

import Foundation
import SwiftUI

struct MoonLampRow: View {
    @ObservedObject var device: MoonLamp
    @ObservedObject var lampService: LampService

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(lampService.state.color)
                    .shadow(radius: 2.0)
                    .frame(width: 50, height: 50)
                    .padding()

                let imageName = lampService.state.isOn ? "lightbulb" : "lightbulb.slash"
                Image(systemName: imageName)
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
            }

            Text("\(device.peripheralName)")

            Spacer()
        }
    }
}

