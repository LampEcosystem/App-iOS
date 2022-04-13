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
    @Published var deviceInfoState = DeviceInfoState()
    
    var serviceUUIDMap = [CBUUID: Service]()
    
    var services: [Service] {
        get {
            return Array(serviceUUIDMap.filter { key, value in
                return key == value.uuid
            }.values)
        }
    }
    
    public var peripheralName: String
    public var managerConnected = false
    
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
        
        self.registerServices()
        self.setupPeripheral()
    }
    
    public func refresh() {}
    
    public func isConnected() -> Bool {
        return managerConnected
    }
    
    func registerServices() {
        registerService(DeviceInfoService(self, peripheral: devicePeripheral!))
        registerService(UtilityService(self, peripheral: devicePeripheral!))
        registerService(WifiService(self, peripheral: devicePeripheral!))
        registerService(AssociationService(self, peripheral: devicePeripheral!))
    }
    
    func registerUUIDToService(_ service: Service, uuid: CBUUID) {
        serviceUUIDMap[uuid] = service
    }
    
    func registerService(_ service: Service) {
        registerUUIDToService(service, uuid: service.uuid)
    }
    
    func getService(_ uuid: CBUUID) -> Service? {
        return serviceUUIDMap[uuid]
    }
}

extension Device: CBPeripheralDelegate {
    
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
        guard let srv = serviceUUIDMap[service.uuid] else { return }
        
        srv.registerCharacteristics(peripheral, service: service, characteristics: characteristics)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let service = serviceUUIDMap[characteristic.uuid] else { return }
        
        service.didUpdateValueFor(peripheral, characteristic: characteristic, error: error)
    }
}
