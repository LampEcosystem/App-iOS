//
//  LampState.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import SwiftUI

struct RGBLampState: ServiceState, Equatable {
    var isConnected = false
    var hue: Double = 0.0
    var saturation: Double = 1.0
    var brightness: Double = 1.0
    var isOn = false
    
    var color: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    var baseHueColor: Color {
        Color(hue: hue, saturation: 1.0, brightness: 1.0)
    }
}
