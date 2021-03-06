//
//  AppDelegate.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/16.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let navDelegate = FENavigationControllerDelegate()
    var window: UIWindow?    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {

        } else {
            // Fallback on earlier versions
//            let photos = FECommon.buildData()
//            // Override point for customization after application launch.
//            let tab = FEBaseTabBarViewController()
//            let photo = FEPhotoCollectionController(nibName: "FEPhotoCollectionController", bundle: nil)
//            photo.controllerType = .root
//            photo.photos = photos
//            let nav = FEBaseNavigationController.init(rootViewController: photo)
//            nav.delegate = navDelegate
//            tab.viewControllers = [nav]
//            self.window?.rootViewController = tab
            FECommon.initWindow(navDelegate: navDelegate, window: window)
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        if #available(iOS 13.0, *) {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        } else {
        }
        return UISceneConfiguration()
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

