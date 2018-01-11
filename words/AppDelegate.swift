//
//  AppDelegate.swift
//  words
//
//  Created by Neo Ighodaro on 08/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

struct AppConstants {
    static let ENDPOINT = "http://127.0.0.1:8000"
    static let CLIENT_ID = 2
    static let CLIENT_SECRET = "iQlyOZoA7RPXvFaZBM1iKIFXeu0Hq855a2NV7ERt"
    static let CHATKIT_INSTANCE_ID = "v1:us1:44cc778a-492d-4000-ab1a-abaac05e02fa"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let ud = UserDefaults.standard
        ud.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        ud.synchronize()
        return true
    }
}

