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
    @State private var saveDisabled: Bool = true;
    
    
    init(batteryController: BatteryController){
        self.batteryController = batteryController;
    }
    
    var body: some View {
        VStack {
            Text("Battery Notifier").font(.largeTitle)
            Text("Lower and uppper limits:")
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .padding(.vertical, 20)
            
            HStack{
                Text("Low battery notification:")
                Spacer()
                Text("\(Int(minValue), specifier: "%d") %")
            }.padding(.horizontal, 60)
            Slider(value: $minValue, in: 10...100, step: 1,
                   onEditingChanged: {editing in
                    if(!editing){
                        saveDisabled = isNotChanged()
                    }
                   })
                .padding(.horizontal, 50.0)
                .onAppear(perform: {
                    self.minValue = Double(self.batteryController.minLevel)
                })
            HStack {
                Text("Full battery notification:")
                Spacer()
                Text("\(Int(maxValue), specifier: "%d") %")
            }.padding(.horizontal, 60)
            
            
            Slider(value: $maxValue, in: 10 ... 100, step: 1,
                   onEditingChanged: {editing in
                    if(!editing){
                        saveDisabled = isNotChanged()
                    }
                   })
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
                    saveDisabled = isNotChanged()
                }
            }){
                Text("Save")
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    .cornerRadius(40)
                    .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1))
            }.disabled(saveDisabled)
            Text(errorMessage).padding(.vertical, 10)
                .shadow(color: .red, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                .font(.caption)
            Spacer()
        }.padding(.vertical, 50)
        .border(Color.black, width: 0.3)
    }
    
    func isNotChanged() -> Bool{
        return Int(minValue) == Int(batteryController.minLevel) && Int(maxValue) == Int(batteryController.maxLevel)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(batteryController: BatteryController())
    }
}
