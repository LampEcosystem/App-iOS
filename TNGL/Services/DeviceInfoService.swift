//
//  DeviceInfoService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth

class DeviceInfoService: Service {
    static let SERVICE_UUID = CBUUID(string: "180a")
    static let MANUFACTURER_UUID = CBUUID(string: "2a29")
    static let MODEL_UUID = CBUUID(string: "2a24")
    static let SERIAL_UUID = CBUUID(string: "2a25")
    
    @Published var state = DeviceInfoState()
    
    init(_ device: Device, peripheral: CBPeripheral) {
        super.init(device, peripheral: peripheral, serviceUUID: DeviceInfoService.SERVICE_UUID)
        registerUUID(DeviceInfoService.MANUFACTURER_UUID)
        registerUUID(DeviceInfoService.MODEL_UUID)
        registerUUID(DeviceInfoService.SERIAL_UUID)
    }
}
