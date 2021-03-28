//
//  ContentView.swift
//  Battery-Notifier
//
//  Created by alus on 27.03.2021.
//

import SwiftUI

struct ContentView: View {
    
    var batteryController: BatteryController;
    
    @State private var minValue: Double = 10
    @State private var maxValue : Double = 90
    
    @State private var errorMessage:String = ""
    
    
    init(batteryController: BatteryController){
        self.batteryController = batteryController;
    }
    
    var body: some View {
        VStack {
            Text("Specify lower and uppper limits:")
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding(.vertical, 20)
                .shadow(color: .blue, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
            
            
            Text("Low battery notification: \(Int(minValue), specifier: "%d")")
            
            Slider(value: $minValue, in: 10...80, step: 1)
                .padding(.horizontal, 50.0).onAppear(perform: {
                    self.minValue = Double(self.batteryController.minLevel)
                })
            Text("Full battery notification: \(Int(maxValue), specifier: "%d")")
            
            Slider(value: $maxValue, in: 20 ... 80, step: 1)
                .padding(.horizontal, 50.0).onAppear(perform: {
                    self.maxValue = Double(self.batteryController.maxLevel);
                })
            
            Button(action: {
                if(minValue >= maxValue){
                    errorMessage = "Low value cannot be greater than Full"
                }else{
                    batteryController.minLevel = minValue
                    batteryController.maxLevel = maxValue
                    errorMessage = ""
                }
            }){
                Text("Save")
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    .cornerRadius(40)
                    .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 2))
            }
            Text(errorMessage).padding(.vertical, 10)
                .shadow(color: .red, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
            Spacer()
        }.padding(.vertical, 50)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(batteryController: BatteryController())
    }
}
