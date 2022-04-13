//
//  AssociationService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth

class AssociationService: Service {
    static let SERVICE_UUID = CBUUID(string: "2001A7D3-D8A4-4FEA-8174-1736E808C066")
    static let ASSOCIATION_CODE_UUID = CBUUID(string: "2002A7D3-D8A4-4FEA-8174-1736E808C066")
    static let IS_ASSOCIATED_UUID = CBUUID(string: "2003A7D3-D8A4-4FEA-8174-1736E808C066")
    
    init(_ device: Device, peripheral: CBPeripheral) {
        super.init(device, peripheral: peripheral, serviceUUID: AssociationService.SERVICE_UUID)
        registerUUID(AssociationService.ASSOCIATION_CODE_UUID)
        registerUUID(AssociationService.IS_ASSOCIATED_UUID)
    }
}
