//
//  Lamp.swift
//  MoonLamp
//

import Foundation
import CoreBluetooth
import Combine

class Lamp: Device {
    
    
    override init(name: String) {
        super.init(name: name)
    }

    override init(devicePeripheral: CBPeripheral) {
        super.init(devicePeripheral: devicePeripheral)
    }
}
