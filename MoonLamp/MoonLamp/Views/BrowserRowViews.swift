//
//  BrowserRowViews.swift
//  MoonLamp
//

import Foundation
import SwiftUI

struct MoonLampRow: View {
    @ObservedObject var device: MoonLamp

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(device.state.color)
                    .shadow(radius: 2.0)
                    .frame(width: 50, height: 50)
                    .padding()

                let imageName = device.state.isOn ? "lightbulb" : "lightbulb.slash"
                Image(systemName: imageName)
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
            }

            Text("\(device.peripheralName)")

            Spacer()
        }
    }
}

//private struct DoorbellRow: View {
//    @ObservedObject var device: Doorbell
//
//    var body: some View {
//        HStack {
//            ZStack {
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(device.state.isAssociated ? Color.green : Color.red)
//                    .shadow(radius: 2.0)
//                    .frame(width: 50, height: 50)
//                    .padding()
//
//                Image("Doorbell")
//                    .resizable()
//                    .frame(width: 35, height: 35)
//                    .shadow(radius: 2.0)
//            }
//
//            Text("\(device.name)")
//
//            Spacer()
//        }
//    }
//}
