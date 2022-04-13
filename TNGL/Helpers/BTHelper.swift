//
//  BTHelper.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation

class BTHelper {
    public static func parseBoolean(for value: Data) -> Bool {
        return value.first == 1
    }
    
    public static func parseString(for value: Data) -> String {
        let str = String(decoding: value, as: UTF8.self)
        return str
    }
}
