//
//  WifiSettingsView.swift
//  MoonLamp
//

import Foundation
import SwiftUI

struct WifiSettingsView: View {
    @ObservedObject var device: Device
    @ObservedObject var wifiService: WifiService
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("SSID:")
                        .padding()
                    TextField("SSID", text: $wifiService.state.ssid)
                        .disableAutocorrection(true)
                }
                HStack {
                    Text("Password:")
                        .padding()
                    SecureField("Password", text: $wifiService.state.psk)
                        .disableAutocorrection(true)
                }
                Text(wifiService.state.wifiResponse)
                
                Button(action: {
                    wifiService.sendWifiUpdate()
                    UIApplication.shared.endEditing()
                }, label: {
                    Text("Save")
                }).padding()
            }
        }
        Spacer()
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Wifi Setup", displayMode: .inline)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
                .shadow(radius: 2.0)
        })
        
    }
    
    init(_ device: Device) {
        self.device = device
        self.wifiService = device.getService(WifiService.SERVICE_UUID) as! WifiService
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
