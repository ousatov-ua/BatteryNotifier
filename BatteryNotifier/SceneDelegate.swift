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
    
    override init(){
        userNotificationCenter = UNUserNotificationCenter.current();
        batteryController = BatteryController(userNotificationCenter: userNotificationCenter);
        super.init()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryController.addMyselfAsObserver();
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(batteryController: batteryController)
        
        // Use a UIHostingController as window root view controller.
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
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.alus.product.BatteryMonitor.refresh",
            using: DispatchQueue.global()
        ) { task in
            self.handleAppRefresh(task)
        }
        
        // Additionally we add timer for level check
        Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: true) { (t) in
            self.batteryController.checkBatteryLevel(newValue: self.batteryController.getCurrentLevel())
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(batteryController);
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        scheduleAppRefresh()
        
        batteryController.addMyselfAsObserver()
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        //TODO
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
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
    
    private func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "com.alus.product.BatteryMonitor.refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: backgroundRefreshInterval)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
    
}

