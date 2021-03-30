//
//  SceneDelegate.swift
//  BatteryNotifier
//
//  Created by alus on 27.03.2021.
//

import UIKit
import SwiftUI



class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    
    override init(){
      
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let batteryController = (UIApplication.shared.delegate as! AppDelegate).batteryController
        let contentView = ContentView(batteryController: batteryController)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
     
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
 
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {

    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as! AppDelegate).applicationDidEnterBackground(UIApplication.shared)
    }
}

