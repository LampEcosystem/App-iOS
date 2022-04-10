//
//  UtilityService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth

class UtilityService: Service {
    static let SERVICE_UUID = CBUUID(string: "1001A7D3-D8A4-4FEA-8174-1736E808C066")
    static let NAME_CHARACTERISTIC_UUID = CBUUID(string: "1002A7D3-D8A4-4FEA-8174-1736E808C066")
    
    init(_ device: Device, peripheral: CBPeripheral) {
        super.init(device, peripheral: peripheral, serviceUUID: UtilityService.SERVICE_UUID)
        registerUUID(UtilityService.NAME_CHARACTERISTIC_UUID)
    }
}
