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
import Branch

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
 
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    Branch.setBranchKey("<< BRANCH API KEY>>")
    Branch.useTestBranchKey()
    
    let configurationResolver = ConfigurationResolver()
    configurationResolver.resolve(launchOptions: launchOptions) { configuration in
      
      // SDK initialization
      // Check Configuration.swift for API Key & Environment
      
      AptoPlatform.defaultManager().initializeWithApiKey(
        configuration.apiKey,
        environment: configuration.environment
      )

      AptoPlatform.defaultManager().initializePushNotifications()
      AptoPlatform.defaultManager().handle(launchOptions:launchOptions)
    }

    return true
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
