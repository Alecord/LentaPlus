//
//  AppDelegate.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/21/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.instance.saveContext()
    }
    
}
