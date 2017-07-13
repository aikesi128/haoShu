//
//  AppDelegate.swift
//  haoShu
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        self.window = UIWindow(frame:CGRect(x: 0,y: 0,width: SCREEN_WIDTH,height: SCEREEN_HEIGHT))
        
        let tabbarController = UITabBarController()
        
        let rankController = UINavigationController(rootViewController:rankViewController())

        let searchController = UINavigationController(rootViewController: searchViewController())
        
        let pushController = UINavigationController(rootViewController: pushViewController())
        
        let circleController = UINavigationController(rootViewController: circleViewController())
        
        let moreController = UINavigationController(rootViewController: moreViewController())
        
        tabbarController.viewControllers = [rankController,searchController,pushController,circleController,moreController]

        let tabitem1 = UITabBarItem.init(title: "排行榜", image: UIImage.init(named: "bio"), selectedImage: UIImage.init(named: "bio_red"))
        
        let tabitem2 = UITabBarItem.init(title: "发现", image: UIImage.init(named: "timer 2"), selectedImage: UIImage.init(named: "timer 2"))
        
        let tabitem3 = UITabBarItem.init(title: "", image: UIImage.init(named: "pencil"), selectedImage: UIImage.init(named: "pencil_red"))
        
        let tabitem4 = UITabBarItem.init(title: "圈子", image: UIImage.init(named: "users two-2"), selectedImage: UIImage.init(named: "users two-2_red"))
        
        let tabitem5 = UITabBarItem.init(title: "更多", image: UIImage.init(named: "more"), selectedImage: UIImage.init(named: "more_red"))
   
        
        rankController.tabBarItem = tabitem1
        
        searchController.tabBarItem = tabitem2
        
        pushController.tabBarItem = tabitem3
        
        circleController.tabBarItem = tabitem4
        
        moreController.tabBarItem = tabitem5
        
        tabbarController.tabBar.tintColor = UIColor(colorLiteralRed: 235/255, green: 114/255, blue: 118/255, alpha: 1)
        
        self.window?.rootViewController = tabbarController
        
        self.window?.makeKeyAndVisible()
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

