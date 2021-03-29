//
//  SceneDelegate.swift
//  BatteryNotifier
//
//  Created by alus on 27.03.2021.
//

import UIKit
import SwiftUI
import BackgroundTasks

class AppRefreshOperation : Operation {
    
    let batteryController:BatteryController;
    
    init(batteryController: BatteryController){
        self.batteryController = batteryController;
    }
    
    override func main() {
        batteryController.checkBatteryLevel(newValue: batteryController.getCurrentLevel())
    }
    
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    let batteryController:BatteryController;
    let userNotificationCenter: UNUserNotificationCenter
    let refreshInterval:Double = 5 * 60;
    let backgroundRefreshInterval:Double = 15 * 60
    let bgTaskId = "com.alus.product.BatteryMonitor.refresh"
    
    override init(){
        userNotificationCenter = UNUserNotificationCenter.current();
        batteryController = BatteryController(userNotificationCenter: userNotificationCenter);
        super.init()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryController.addMyselfAsObserver();
       
        let contentView = ContentView(batteryController: batteryController)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        userNotificationCenter.requestAuthorization(options: [.sound, .alert, .carPlay, .badge]) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
        self.userNotificationCenter.delegate = self
        
        if #available(iOS 13, *) {
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: bgTaskId,
                using: DispatchQueue.global()
            ) { task in
                self.handleAppRefresh(task)
            }
        }
        
        // Additionally we add timer for level check
        Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: true) { (t) in
            self.batteryController.checkBatteryLevel(newValue: self.batteryController.getCurrentLevel())
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(batteryController);
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
     
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
 
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {

    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryController.addMyselfAsObserver()
        
        if #available(iOS 13, *) {
            scheduleAppRefresh()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
    
    private func handleAppRefresh(_ task: BGTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let appRefreshOperation = AppRefreshOperation(batteryController: self.batteryController)
        queue.addOperation(appRefreshOperation)
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
        
        scheduleAppRefresh()
    }
    
    @available(iOS 13.0, *)
    private func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: bgTaskId)
            request.earliestBeginDate = Date(timeIntervalSinceNow: backgroundRefreshInterval)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
    
}

