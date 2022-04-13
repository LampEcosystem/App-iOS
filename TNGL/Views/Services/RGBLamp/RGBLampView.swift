//
//  LampView.swift
//  MoonLamp
//

import Foundation
import SwiftUI

struct RGBLampView: View {
    @ObservedObject var lamp: RGBLamp
    @ObservedObject var rgbLampService: RGBLampService
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(rgbLampService.state.color)
                    .edgesIgnoringSafeArea(.top)
                Text("\(rgbLampService.state.isConnected ? "Connected" : "Disconnected")")
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: .infinity)
                                    .fill(Color(white: 0.25, opacity: 0.5)))
                    .padding()
            }
            
            VStack(alignment: .center, spacing: 20) {
                GradientSlider(value: $rgbLampService.state.hue,
                               handleColor: rgbLampService.state.baseHueColor,
                               trackColors: Color.rainbow()) { hueValue in
                }
                
                GradientSlider(value: $rgbLampService.state.saturation,
                               handleColor: Color(hue: rgbLampService.state.hue,
                                                  saturation: rgbLampService.state.saturation,
                                                  brightness: 1.0),
                               trackColors: [.white, rgbLampService.state.baseHueColor]) { saturationValue in
                }
                
                GradientSlider(value: $rgbLampService.state.brightness,
                               handleColor: Color(white: rgbLampService.state.brightness),
                               handleImage: Image(systemName: "sun.max"),
                               trackColors: [.black, .white]) { brightnessValue in
                }
                .foregroundColor(Color(white: 1.0 - rgbLampService.state.brightness))
            }.padding(.horizontal)
            
            Button(action: {
                rgbLampService.state.isOn.toggle()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "power")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                }.padding()
            }
            .foregroundColor(rgbLampService.state.isOn ? rgbLampService.state.color : .gray)
            .background(Color.black.edgesIgnoringSafeArea(.bottom))
            .frame(height: 100)
        }
        .disabled(!rgbLampService.state.isConnected)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            Image(systemName: "arrow.left")
                .foregroundColor(.white)
                .shadow(radius: 2.0)
        }, trailing:
                                NavigationLink(destination: WifiSettingsView(lamp)) {
                Image(systemName: "gear")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
            })
        .onAppear(perform: rgbLampService.refresh)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            rgbLampService.refresh()
        }
    }
    
    init(_ lamp: RGBLamp) {
        self.lamp = lamp
        self.rgbLampService = lamp.getService(RGBLampService.SERVICE_UUID) as! RGBLampService
    }
}

struct MoonLampView_Previews: PreviewProvider {
    static var previews: some View {
        RGBLampView(RGBLamp(name: "test lamp device"))
    }
}
