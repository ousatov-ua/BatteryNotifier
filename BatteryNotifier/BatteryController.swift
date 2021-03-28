//
//  BatteryController.swift
//  BatteryNotifier
//
//  Created by alus on 27.03.2021.
//

import Foundation
import UserNotifications
import SwiftUI

struct Settings {
    static let minLevel = "minLevel"
    static let maxLevel = "maxLevel"
}

enum Action {
    case Connect
    case Disconnect
    case Nothing
}

class BatteryController {
    let defaultMin:Double = 20;
    let defaultMax:Double = 80;
    let userDefaults:UserDefaults
    var currentLevel:Int = -1;
    
    let userNotificationCenter:UNUserNotificationCenter
    
    init(userDefaults: UserDefaults = .standard, userNotificationCenter: UNUserNotificationCenter = .current()){
        self.userDefaults = userDefaults;
        self.userNotificationCenter = userNotificationCenter
        
    }
    
    func addMyselfAsObserver() -> Void{
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.levelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil)
    }
    
    var minLevel:Double {
        get {
            if let val = userDefaults.double(forKey: Settings.minLevel) as Double? {
                return val;
            }
            return defaultMin;
        }
        set {
            self.userDefaults.setValue(newValue, forKey: Settings.minLevel)
            self.userDefaults.synchronize();
        }
    }
    var maxLevel:Double {
        get{
            if let val = userDefaults.double(forKey: Settings.maxLevel) as Double? {
                return val;
            }
            return defaultMax;
        }
        set {
                self.userDefaults.setValue(newValue, forKey: Settings.maxLevel)
                self.userDefaults.synchronize();
        }
    }

    @objc func levelChanged(notification: Notification) {
        if let value = notification.object as? Float{
            checkBatteryLevel(newValue: value)
        }       
    }
    
    func checkBatteryLevel(newValue: Float){
        let newValueInt:Int = Int(newValue * 100)
        var action:Action = Action.Nothing;
        if(newValueInt < Int(self.minLevel)){
            action = Action.Connect
        }else if(newValueInt > Int(self.maxLevel)){
            action = Action.Disconnect
        }
        var send:Bool = false
        if(currentLevel == -1){
            switch action {
            case .Connect:
                currentLevel = Int(self.maxLevel)
                send = true
            case .Disconnect:
                currentLevel = Int(self.minLevel)
                send = true
            default:
                currentLevel = -1
            }
        }else if(currentLevel == Int(self.minLevel) && action == .Connect){
                currentLevel = Int(self.maxLevel)
            send = true
        } else if(currentLevel == Int(self.maxLevel) && action  == .Disconnect){
                currentLevel = Int(self.minLevel)
            send = true
        }
  
        if(send){
        sendNotification(Action.Connect)
        }
    }
    
    func getCurrentLevel()-> Float{
        return UIDevice.current.batteryLevel

    }
    
    func sendNotification(_ action: Action) -> Void {
        // Create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()

        // Add the content to the notification content
        
        var body: String;
        switch action {
        case .Connect:
            body = "Charge your device";
        default:
            body = "Disconnect from charging";
        }
        notificationContent.title = "Battery Notification"
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "Battery Notification",
                                            content: notificationContent,
                                            trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}
