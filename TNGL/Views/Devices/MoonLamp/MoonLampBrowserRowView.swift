//
//  MoonLampBrowserRowView.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/12/22.
//

import Foundation
import SwiftUI

struct MoonLampBrowserRow: View {
    @ObservedObject var device: MoonLamp
    @ObservedObject var lampService: RGBLampService

    var body: some View {
        NavigationLink(destination: RGBLampView(device as RGBLamp)) {
            HStack {
                let imageName = lampService.state.isOn ? "lightbulb" : "lightbulb.slash"
                ImageSquare(fillColor: lampService.state.color, imageName: imageName)

                Text("\(device.peripheralName)")

                Spacer()
            }
        }
    }
    
    init(_ device: MoonLamp) {
        self.device = device
        self.lampService = device.getService(RGBLampService.SERVICE_UUID) as! RGBLampService
    }
}
