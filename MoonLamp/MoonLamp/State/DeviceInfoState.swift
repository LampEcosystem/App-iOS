//
//  DeviceInfoState.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation

struct DeviceInfoState: ServiceState, Equatable {
    var manufacturer = ""
    var model = ""
    var serial = ""
}
