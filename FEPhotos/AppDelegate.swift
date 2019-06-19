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


    var window: UIWindow?
    
    func buildData() -> [FEPhotoCellData] {
        let year = [2019,2018,2017]
        let month = [1,2,3,4,5,6,7,8,9,10,11,12]
        var day = [Int]()
        let address = ["四川省","广东省",""]
        //直接全部26天..
        for i in 1...26 {
            day.append(i)
        }
        var photos = [FEPhotoCellData]()
        for i in 1...154 {
            let data = FEPhotoCellData()
            let y = year.randomElement()
            let m = month.randomElement()
            let d = day.randomElement()
            let image = String(i) + ".jpg"
            let smallimage = "small_" + String(i) + ".jpg"

            data.year = y
            data.month = m
            data.day = d
            data.smallImagePath = smallimage
            data.middleImagePath = image
            data.bigImagePath = image
            data.orginImagePath = image
            data.address = address.randomElement()
            photos.append(data)
        }
        //排序
        photos.sort(by: { (a,b) in
            var c1 = DateComponents()
            let dupCal = Calendar.current
            c1.year = a.year
            c1.month = a.month
            c1.day = a.day
            c1.hour = 0
            c1.minute = 0
            c1.second = 0
            c1.calendar = dupCal
            
            var c2 = DateComponents()
            c2.year = b.year
            c2.month = b.month
            c2.day = b.day
            c2.hour = 0
            c2.minute = 0
            c2.second = 0
            c2.calendar = dupCal
            
            return c1.date! < c2.date!
        })
        return photos
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {

        } else {
            // Fallback on earlier versions
            let photos = self.buildData()
            // Override point for customization after application launch.
            let tab = FEBaseTabBarViewController()
            let photo = FEPhotoCollectionController(nibName: "FEPhotoCollectionController", bundle: nil)
            photo.controllerType = .root
            photo.photos = photos
            let nav = FEBaseNavigationController.init(rootViewController: photo)
            tab.viewControllers = [nav]
            self.window?.rootViewController = tab
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

