//
//  LampView.swift
//  MoonLamp
//

import Foundation
import SwiftUI

struct LampView: View {
    @ObservedObject var lamp: Lamp
    @ObservedObject var lampService: LampService
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(lampService.state.color)
                    .edgesIgnoringSafeArea(.top)
                Text("\(lampService.state.isConnected ? "Connected" : "Disconnected")")
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: .infinity)
                                    .fill(Color(white: 0.25, opacity: 0.5)))
                    .padding()
            }
            
            VStack(alignment: .center, spacing: 20) {
                GradientSlider(value: $lampService.state.hue,
                               handleColor: lampService.state.baseHueColor,
                               trackColors: Color.rainbow()) { hueValue in
                }
                
                GradientSlider(value: $lampService.state.saturation,
                               handleColor: Color(hue: lampService.state.hue,
                                                  saturation: lampService.state.saturation,
                                                  brightness: 1.0),
                               trackColors: [.white, lampService.state.baseHueColor]) { saturationValue in
                }
                
                GradientSlider(value: $lampService.state.brightness,
                               handleColor: Color(white: lampService.state.brightness),
                               handleImage: Image(systemName: "sun.max"),
                               trackColors: [.black, .white]) { brightnessValue in
                }
                .foregroundColor(Color(white: 1.0 - lampService.state.brightness))
            }.padding(.horizontal)
            
            Button(action: {
                lampService.state.isOn.toggle()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "power")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                }.padding()
            }
            .foregroundColor(lampService.state.isOn ? lampService.state.color : .gray)
            .background(Color.black.edgesIgnoringSafeArea(.bottom))
            .frame(height: 100)
        }
        .disabled(!lampService.state.isConnected)
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
        .onAppear(perform: lampService.refresh)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            lampService.refresh()
        }
    }
    
    init(_ lamp: Lamp) {
        self.lamp = lamp
        self.lampService = lamp.getService(LampService.SERVICE_UUID) as! LampService
    }
}

struct MoonLampView_Previews: PreviewProvider {
    static var previews: some View {
        LampView(Lamp(name: "test lamp device"))
    }
}
