//
//  BLEService.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation
import CoreBluetooth
import SwiftUI

class Service {
    var service: CBService
    var characteristics = [CBUUID: CBCharacteristic]()
    var state: ServiceState
    
    init(_ service: CBService) {
        self.service = service
    }
    
    func canRespondToCharacteristic(_ characteristic: CBCharacteristic) -> Bool {
        return characteristics[characteristic.uuid] != nil
    }
}

