//
//  AppDelegate.swift
//  TEST
//
//  Created by Ivan Oliver on 01/25/2016.
//  Copyright (c) 2016 Ivan Oliver. All rights reserved.
//

import UIKit
import AptoSDK
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // SDK initialization
    AptoPlatform.defaultManager().initializeWithApiKey("<Api Key>",
                                                        environment: .production)

    AptoPlatform.defaultManager().initializePushNotifications()
    AptoPlatform.defaultManager().handle(launchOptions:launchOptions)

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {}

  func applicationDidEnterBackground(_ application: UIApplication) {}

  func applicationWillEnterForeground(_ application: UIApplication) {}

  func applicationDidBecomeActive(_ application: UIApplication) {}

  func applicationWillTerminate(_ application: UIApplication) {}

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return false
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    AptoPlatform.defaultManager().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    AptoPlatform.defaultManager().didFailToRegisterForRemoteNotificationsWithError(error: error)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    AptoPlatform.defaultManager().didReceiveRemoteNotificationWith(userInfo: userInfo, completionHandler: completionHandler)
  }

}
