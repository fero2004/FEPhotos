//
//  SceneDelegate.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/16.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import SwifterSwift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

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
            let image = UIImage.init(named: String(i) + ".jpg")
            
            data.year = y
            data.month = m
            data.day = d
            data.smallImage = image
            data.middleImage = image
            data.bigImage = image
            data.orginImage = image
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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let photos = self.buildData()
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let tab = FEBaseTabBarViewController()
        let photo = FEPhotoCollectionController(nibName: "FEPhotoCollectionController", bundle: nil)
        photo.controllerType = .root
        let nav = FEBaseNavigationController.init(rootViewController: photo)
        tab.viewControllers = [nav]
        self.window?.rootViewController = tab
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

