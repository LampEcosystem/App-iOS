//
//  WifiService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth

class WifiService: Service {
    static let SERVICE_UUID = CBUUID(string: "3001A7D3-D8A4-4FEA-8174-1736E808C066")
    static let SSID_UUID = CBUUID(string: "3002A7D3-D8A4-4FEA-8174-1736E808C066")
    static let PSK_UUID = CBUUID(string: "3003A7D3-D8A4-4FEA-8174-1736E808C066")
    static let WIFI_UPDATE_UUID = CBUUID(string: "3004A7D3-D8A4-4FEA-8174-1736E808C066")
    
    @Published var state = WifiState()
    
    init(_ device: Device, peripheral: CBPeripheral) {
        super.init(device, peripheral: peripheral, serviceUUID: WifiService.SERVICE_UUID)
        registerUUID(WifiService.SSID_UUID)
        registerUUID(WifiService.PSK_UUID)
        registerUUID(WifiService.WIFI_UPDATE_UUID)
    }
}

extension WifiService {
    private func sendWifiConfiguration(force: Bool = false) {
        if isReady() {
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
        if let ssidCharacteristic = characteristics[WifiService.SSID_UUID] {
            let valueString = (state.ssid as NSString).data(using: String.Encoding.utf8.rawValue)
            peripheral.writeValue(valueString!, for: ssidCharacteristic, type: .withResponse)
        }
    }
    
    private func writePSK() {
        if let pskCharacteristic = characteristics[WifiService.PSK_UUID] {
            let valueString = (state.psk as NSString).data(using: String.Encoding.utf8.rawValue)
            peripheral.writeValue(valueString!, for: pskCharacteristic, type: .withResponse)
        }
    }
    
    private func writeUpdate() {
        if let wifiUpdateCharacteristic = characteristics[WifiService.WIFI_UPDATE_UUID] {
            var val: UInt8 = 5
            let data = Data(bytes: &val, count: 1)
            peripheral.writeValue(data, for: wifiUpdateCharacteristic, type: .withResponse)
        }
    }
    
    public func sendWifiUpdate() {
        sendWifiConfiguration()
    }
}
