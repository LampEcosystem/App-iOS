//
//  Lamp.swift
//  MoonLamp
//

import Foundation
import CoreBluetooth
import Combine

class RGBLamp: Device {
    
    
    override init(name: String) {
        super.init(name: name)
    }

    override init(devicePeripheral: CBPeripheral) {
        super.init(devicePeripheral: devicePeripheral)
    }
    
    override func registerServices() {
        super.registerServices()
        self.registerService(RGBLampService(self, peripheral: devicePeripheral!))
    }
}
