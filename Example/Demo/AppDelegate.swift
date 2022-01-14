//
//  AppDelegate.swift
//  TEST
//
//  Created by Ivan Oliver on 01/25/2016.
//  Copyright (c) 2016 Ivan Oliver. All rights reserved.
//

import AlamofireNetworkActivityLogger
import AptoSDK
import Branch
import Sentry
import UIKit
import UserNotifications

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configurationResolver = ConfigurationResolver()
        configurationResolver.resolve(launchOptions: launchOptions) { configuration in

            // SDK initialization
            // Check Configuration.swift for API Key & Environment

            AptoPlatform.defaultManager().initializeWithApiKey(
                configuration.apiKey,
                environment: configuration.environment
            )

            AptoPlatform.defaultManager().initializePushNotifications()
            AptoPlatform.defaultManager().handle(launchOptions: launchOptions)
        }
        #if DEBUG
            NetworkActivityLogger.shared.level = .debug
            NetworkActivityLogger.shared.startLogging()
        #endif
        SentrySDK.start { options in
            options.dsn = "https://38a383fcaf494b0e93b6f2537c574aeb@o21951.ingest.sentry.io/5518327"
            options.debug = true
        }
        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AptoPlatform.defaultManager().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AptoPlatform.defaultManager().didFailToRegisterForRemoteNotificationsWithError(error: error)
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AptoPlatform.defaultManager().didReceiveRemoteNotificationWith(userInfo: userInfo, completionHandler: completionHandler)
    }
}
