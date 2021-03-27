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
}

class BatteryController {
    let defaultMin:Double = 20;
    let defaultMax:Double = 80;
    let userDefaults:UserDefaults
    var currentLevel:Float = -1;
    
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
            checkBatteryLevel(value: value)
        }       
    }
    
    func checkBatteryLevel(value: Float){
        
        /*var currentValue:Float = -1;
        var currentValueInt:Int
        var currentLevelInt:Int = Int(currentLevel)
        var action:Action
        if let value = notification.object as? Float{
            currentValue = value*100
            currentValueInt = Int(currentValue)
            if(currentValueInt <= Int(self.defaultMin)){
                currentLevel = defaultMin;
                
            }else if(currentValueInt >= Int(self.maxLevel)){
                action = Action.Disconnect
            }
        } */
        sendNotification(Action.Connect)
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
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    
}
