//
//  Lamp.swift
//  MoonLamp
//

import Foundation
import CoreBluetooth
import Combine
import SwiftUI

class Lamp: Device {
    var state = State() {
        didSet {
            if oldValue != state {
                updateDevice()
            }
        }
        willSet {
            self.objectWillChange.send()
        }
    }
    
    override init(name: String) {
        super.init(name: name)
    }

    override init(devicePeripheral: CBPeripheral) {
        super.init(devicePeripheral: devicePeripheral)
    }
    
    override func isConnected() -> Bool {
        print("checkiung connected")
        print(characteristics)
        return super.isConnected() && characteristics[Lamp.HSV_UUID] != nil && characteristics[Lamp.BRIGHTNESS_UUID] != nil && characteristics[Lamp.ON_OFF_UUID] != nil
    }
    
    override func refresh() {
        if let peripheral = devicePeripheral {
            if let hsvCharacteristic = characteristics[Lamp.HSV_UUID] {
                peripheral.readValue(for: hsvCharacteristic)
            }
            if let brightnessCharacteristic = characteristics[Lamp.BRIGHTNESS_UUID] {
                peripheral.readValue(for: brightnessCharacteristic)
            }
            if let onOffCharacteristic = characteristics[Lamp.ON_OFF_UUID] {
                peripheral.readValue(for: onOffCharacteristic)
            }
        }
    }
    
    override func registerCharacteristic(peripheral: CBPeripheral, service: CBService, characteristic: CBCharacteristic) {
        super.registerCharacteristic(peripheral: peripheral, service: service, characteristic: characteristic)
        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    override func postCharacteristicRegistration() {
        if self.characteristics[Lamp.HSV_UUID] != nil && self.characteristics[Lamp.BRIGHTNESS_UUID] != nil && self.characteristics[Lamp.ON_OFF_UUID] != nil {
            skipNextDeviceUpdate = true
            state.isConnected = true
        }
    }
}

/*
 * Define state
 */
extension Lamp {
    struct State: Equatable {
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
}

extension Lamp {
    static let LAMP_SERVICE_UUID = CBUUID(string: "0001A7D3-D8A4-4FEA-8174-1736E808C066")
    static let HSV_UUID = CBUUID(string: "0002A7D3-D8A4-4FEA-8174-1736E808C066")
    static let BRIGHTNESS_UUID = CBUUID(string: "0003A7D3-D8A4-4FEA-8174-1736E808C066")
    static let ON_OFF_UUID = CBUUID(string: "0004A7D3-D8A4-4FEA-8174-1736E808C066")
    
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
        if let hsvCharacteristic = characteristics[Lamp.HSV_UUID] {
            var hsv: UInt32 = 0
            let hueInt = UInt32(state.hue * 255.0)
            let satInt = UInt32(state.saturation * 255.0)
            let valueInt = UInt32(255)
            
            hsv = hueInt
            hsv += satInt << 8
            hsv += valueInt << 16
            
            let data = Data(bytes: &hsv, count: 3)
            devicePeripheral?.writeValue(data, for: hsvCharacteristic, type: .withResponse)
        }
    }
    
    internal func writeBrightness() {
        if let brightnessCharacteristic = characteristics[Lamp.BRIGHTNESS_UUID] {
            var brightnessChar = UInt8(state.brightness * 255.0)
            let data = Data(bytes: &brightnessChar, count: 1)
            devicePeripheral?.writeValue(data, for: brightnessCharacteristic, type: .withResponse)
        }
    }
    
    internal func writeOnOff() {
        if let onOffCharacteristic = characteristics[Lamp.ON_OFF_UUID] {
            let data = Data(bytes: &state.isOn, count: 1)
            devicePeripheral?.writeValue(data, for: onOffCharacteristic, type: .withResponse)
        }
    }
}

/*
 * Bluetooth
 */
extension Lamp {
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        
        skipNextDeviceUpdate = true

        guard let updatedValue = characteristic.value,
              !updatedValue.isEmpty else { return }

        switch characteristic.uuid {
        case Lamp.HSV_UUID:

            var newState = state

            let hsv = parseHSV(for: updatedValue)
            newState.hue = hsv.hue
            newState.saturation = hsv.saturation

            state = newState

        case Lamp.BRIGHTNESS_UUID:
            state.brightness = parseBrightness(for: updatedValue)

        case Lamp.ON_OFF_UUID:
            state.isOn = parseOnOff(for: updatedValue)

        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
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
