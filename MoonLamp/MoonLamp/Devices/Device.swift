//
//  Device.swift
//  MoonLamp
//

import Foundation
import CoreBluetooth
import Combine

class Device: NSObject, ObservableObject {
    @Published var associationState = AssociationState()
    @Published var wifiState = WifiState()
    @Published var utilitystate = UtilityState()
    
    internal var characteristics = [CBUUID: CBCharacteristic]()
    
    public var peripheralName: String
    public var managerConnected = false
    
    public var skipNextDeviceUpdate = false
    public var pendingBluetoothUpdate = false
    
    public func setupPeripheral() {
        if let devicePeripheral = devicePeripheral {
            devicePeripheral.delegate = self
        }
    }
    
    var devicePeripheral: CBPeripheral? {
        didSet {
            setupPeripheral()
        }
    }
    
    init(name: String) {
        self.peripheralName = name
        super.init()
    }
    
    init(devicePeripheral: CBPeripheral) {
        guard let peripheralName = devicePeripheral.name else {
            fatalError("Peripheral must have a name")
        }
        
        self.devicePeripheral = devicePeripheral
        self.peripheralName = peripheralName
        
        super.init()
        
        self.setupPeripheral()
    }
    
    public func refresh() {}
    
    public func isConnected() -> Bool {
        return managerConnected
    }
    
    func registerCharacteristic(peripheral: CBPeripheral, service: CBService, characteristic: CBCharacteristic) {
        self.characteristics[characteristic.uuid] = characteristic
        print(characteristic)
    }
}

/*
 * DEVICE INFO SERVICE EXTENSION
 */
// TODO: Implement methods for fetching this data
extension Device {
    static let DEVICE_INFO_SERVICE_UUID = CBUUID(string: "180a")
    static let MANUFACTURER_UUID = CBUUID(string: "2a29")
    static let MODEL_UUID = CBUUID(string: "2a24")
    static let SERIAL_UUID = CBUUID(string: "2a25")
    
    struct DeviceInfo: Equatable {
        var manufacturer = ""
        var model = ""
        var serial = ""
    }
}


/*
 * WIFI SERVICE EXTENSION
 */
extension Device {
    static let WIFI_SERVICE_UUID = CBUUID(string: "08c7042c-12da-49e8-845e-6086d18a81fa")
    static let SSID_UUID = CBUUID(string: "18c7042c-12da-49e8-845e-6086d18a81fa")
    static let PSK_UUID = CBUUID(string: "28c7042c-12da-49e8-845e-6086d18a81fa")
    static let WIFI_UPDATE_UUID = CBUUID(string: "38c7042c-12da-49e8-845e-6086d18a81fa")
    
    struct WifiState: Equatable {
        var ssid = ""
        var psk = ""
        var wifiResponse = ""
    }

    
    private func sendWifiConfiguration(force: Bool = false) {
        if isConnected() {
            pendingBluetoothUpdate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.writeSSID()
                self?.writePSK()
                self?.writeUpdate()
                
                self?.pendingBluetoothUpdate = false
            }
        }
    }
    
    private func writeSSID() {
        if let ssidCharacteristic = characteristics[Device.SSID_UUID] {
            let valueString = (wifiState.ssid as NSString).data(using: String.Encoding.utf8.rawValue)
            devicePeripheral?.writeValue(valueString!, for: ssidCharacteristic, type: .withResponse)
        }
    }
    
    private func writePSK() {
        if let pskCharacteristic = characteristics[Device.PSK_UUID] {
            let valueString = (wifiState.psk as NSString).data(using: String.Encoding.utf8.rawValue)
            devicePeripheral?.writeValue(valueString!, for: pskCharacteristic, type: .withResponse)
        }
    }
    
    private func writeUpdate() {
        if let wifiUpdateCharacteristic = characteristics[Device.WIFI_UPDATE_UUID] {
            var val: UInt8 = 5
            let data = Data(bytes: &val, count: 1)
            devicePeripheral?.writeValue(data, for: wifiUpdateCharacteristic, type: .withResponse)
        }
    }
    
    public func sendWifiUpdate() {
        sendWifiConfiguration()
    }
}
    

/*
 * ASSOCIATION SERVICE EXTENSION
 */
extension Device {
    static let ASSOCIATION_SERVICE_UUID = CBUUID(string: "4ACB")
    static let ASSOCIATION_CODE_CHARACTERISTIC_UUID = CBUUID(string: "4ACB")
    static let IS_ASSOCIATED_CHARACTERISTIC_UUID = CBUUID(string: "4ACB")
    
    struct AssociationState: Equatable {
        var associationCode = ""
        var isAssociated = false
    }
}


/*
 * UTILITY SERVICE EXTENSION
 */
extension Device {
    static let UTILITY_SERVICE_UUID = CBUUID(string: "")
    static let NAME_CHARACTERISTIC_UUID = CBUUID(string: "")
    
    struct UtilityState: Equatable {
        var name = ""
    }
}

extension Device: CBPeripheralDelegate {
    public var shouldSkipUpdateDevice: Bool {
        return skipNextDeviceUpdate || pendingBluetoothUpdate
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Found: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        managerConnected = true
        print(managerConnected)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            registerCharacteristic(peripheral: peripheral, service: service, characteristic: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    }
    
    public func parseBoolean(for value: Data) -> Bool {
        return value.first == 1
    }
    
    public func parseString(for value: Data) -> String {
        let str = String(decoding: value, as: UTF8.self)
        return str
    }
}
