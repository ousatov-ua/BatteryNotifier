//
//  AppDelegate.swift
//  BatteryNotifier
//
//  Created by alus on 27.03.2021.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    let batteryController:BatteryController;
    let userNotificationCenter: UNUserNotificationCenter
    let refreshInterval:Double = 5 * 60;
    let backgroundRefreshInterval:Double = 15 * 60
    let bgTaskId = "com.alus.product.BatteryMonitor.refresh"

    override init() {
        userNotificationCenter = UNUserNotificationCenter.current();
        batteryController = BatteryController(userNotificationCenter: userNotificationCenter);
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryController.addMyselfAsObserver();
        
        userNotificationCenter.requestAuthorization(options: [.sound, .alert, .carPlay, .badge]) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
        self.userNotificationCenter.delegate = self
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Additionally we add timer for level check
        Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: true) { (t) in
            self.batteryController.checkBatteryLevel(newValue: self.batteryController.getCurrentLevel())
        }
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        NotificationCenter.default.removeObserver(batteryController);
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler:
                     @escaping (UIBackgroundFetchResult) -> Void) {
        batteryController.checkBatteryLevel(newValue: batteryController.getCurrentLevel())
        completionHandler(.noData)
    }
    
  
    
    func applicationDidEnterBackground(_ application: UIApplication){
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryController.addMyselfAsObserver()
    }

}

