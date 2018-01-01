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
    static let CLIENT_SECRET = "RqoE72h8UqoLcsUijFDrqUvHKJNxyEVpuS88Vt0A"
    static let CHATKIT_INSTANCE_ID = "v1:us1:4fa1659f-30e3-41d8-832e-ade625a326fe"
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

