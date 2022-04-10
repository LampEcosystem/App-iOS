//
//  BLEService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth
import SwiftUI

class Service: ObservableObject {
    var uuid: CBUUID
    var device: Device
    var peripheral: CBPeripheral
    var uuids = [CBUUID]()
    var characteristics = [CBUUID: CBCharacteristic]()
    
    var skipNextDeviceUpdate = false
    var pendingBluetoothUpdate = false
    
    var shouldSkipUpdateDevice: Bool {
        return skipNextDeviceUpdate || pendingBluetoothUpdate
    }
    
    init(_ device: Device, peripheral: CBPeripheral, serviceUUID: CBUUID) {
        self.device = device
        self.peripheral = peripheral
        self.uuid = serviceUUID
        registerUUID(self.uuid)
    }
    
    func canProcessCharacteristic(_ characteristic: CBCharacteristic) -> Bool {
        return characteristics[characteristic.uuid] != nil
    }
    
    func isReady() -> Bool {
        for uuid in uuids {
            if (characteristics[uuid] == nil) {
                return false
            }
        }
        return true
    }
    
    func registerUUID(_ uuid: CBUUID) {
        uuids.append(uuid)
        device.registerUUIDToService(self, uuid: uuid)
    }
    
    func registerCharacteristics(_ peripheral: CBPeripheral, service: CBService, characteristics: [CBCharacteristic]) {
        for characteristic in characteristics {
            self.characteristics[characteristic.uuid] = characteristic
            postRegisterCharacteristic(characteristic)
        }
        postRegisterCharacteristics()
    }
    
    func postRegisterCharacteristic(_ characteristic: CBCharacteristic) {}
    
    func postRegisterCharacteristics() {}
    
    func didUpdateValueFor(_ peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {}
}

