//
//  LampService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth
import SwiftUI

class LampService: Service {
    static let SERVICE_UUID = CBUUID(string: "0001A7D3-D8A4-4FEA-8174-1736E808C066")
    static let HSV_UUID = CBUUID(string: "0002A7D3-D8A4-4FEA-8174-1736E808C066")
    static let BRIGHTNESS_UUID = CBUUID(string: "0003A7D3-D8A4-4FEA-8174-1736E808C066")
    static let ON_OFF_UUID = CBUUID(string: "0004A7D3-D8A4-4FEA-8174-1736E808C066")
    
    
    
    @Published var state = LampState() {
        didSet {
            if oldValue != state {
                updateDevice()
            }
        }
        willSet {
            self.objectWillChange.send()
        }
    }
    
    init(_ device: Device, peripheral: CBPeripheral) {
        super.init(device, peripheral: peripheral, serviceUUID: LampService.SERVICE_UUID)
        registerUUID(LampService.HSV_UUID)
        registerUUID(LampService.BRIGHTNESS_UUID)
        registerUUID(LampService.ON_OFF_UUID)
    }
    
    func refresh() {
        if let hsvCharacteristic = characteristics[LampService.HSV_UUID] {
            peripheral.readValue(for: hsvCharacteristic)
        }
        if let brightnessCharacteristic = characteristics[LampService.BRIGHTNESS_UUID] {
            peripheral.readValue(for: brightnessCharacteristic)
        }
        if let onOffCharacteristic = characteristics[LampService.ON_OFF_UUID] {
            peripheral.readValue(for: onOffCharacteristic)
        }
    }
    
    override func postRegisterCharacteristics() {
        if (isReady()) {
            skipNextDeviceUpdate = true
            state.isConnected = true
        } else {
            state.isConnected = false
        }
    }
    
    override func postRegisterCharacteristic(_ characteristic: CBCharacteristic) {
        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    override func didUpdateValueFor(_ peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {
        super.didUpdateValueFor(peripheral, characteristic: characteristic, error: error)
        
        skipNextDeviceUpdate = true

        guard let updatedValue = characteristic.value,
              !updatedValue.isEmpty else { return }

        switch characteristic.uuid {
        case LampService.HSV_UUID:

            var newState = state

            let hsv = parseHSV(for: updatedValue)
            newState.hue = hsv.hue
            newState.saturation = hsv.saturation

            state = newState

        case LampService.BRIGHTNESS_UUID:
            state.brightness = parseBrightness(for: updatedValue)

        case LampService.ON_OFF_UUID:
            state.isOn = parseOnOff(for: updatedValue)

        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}

extension LampService {
    internal func updateDevice(force: Bool = false) {
        if state.isConnected && (force || !shouldSkipUpdateDevice) {
            pendingBluetoothUpdate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.writeOnOff()
                self?.writeBrightness()
                self?.writeHSV()
                
                self?.pendingBluetoothUpdate = false
            }
        }
        
        skipNextDeviceUpdate = false
    }
    
    internal func writeHSV() {
        if let hsvCharacteristic = characteristics[LampService.HSV_UUID] {
            var hsv: UInt32 = 0
            let hueInt = UInt32(state.hue * 255.0)
            let satInt = UInt32(state.saturation * 255.0)
            let valueInt = UInt32(255)
            
            hsv = hueInt
            hsv += satInt << 8
            hsv += valueInt << 16
            
            let data = Data(bytes: &hsv, count: 3)
            peripheral.writeValue(data, for: hsvCharacteristic, type: .withResponse)
        }
    }
    
    internal func writeBrightness() {
        if let brightnessCharacteristic = characteristics[LampService.BRIGHTNESS_UUID] {
            var brightnessChar = UInt8(state.brightness * 255.0)
            let data = Data(bytes: &brightnessChar, count: 1)
            peripheral.writeValue(data, for: brightnessCharacteristic, type: .withResponse)
        }
    }
    
    internal func writeOnOff() {
        if let onOffCharacteristic = characteristics[LampService.ON_OFF_UUID] {
            let data = Data(bytes: &state.isOn, count: 1)
            peripheral.writeValue(data, for: onOffCharacteristic, type: .withResponse)
        }
    }
}

extension LampService {
    private func parseOnOff(for value: Data) -> Bool {
        return value.first == 1
    }

    private func parseHSV(for value: Data) -> (hue: Double, saturation: Double) {
        return (hue: Double(value[0]) / 255.0,
                saturation: Double(value[1]) / 255.0)
    }

    private func parseBrightness(for value: Data) -> Double {
        return Double(value[0]) / 255.0
    }
}
