//
//  AppDelegate.swift
//  words
//
//  Created by Neo Ighodaro on 08/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

struct AppConstants {
    static let ENDPOINT: String = "http://127.0.0.1:8000"
    static let CLIENT_ID: Int = 2
    static let CLIENT_SECRET: String = "nneBZLH70o0Ez9rtpOYCBOzbarrcYpDVLCjnUTdn"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        let ud = UserDefaults.standard
//        ud.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//        ud.synchronize()
        return true
    }
}

