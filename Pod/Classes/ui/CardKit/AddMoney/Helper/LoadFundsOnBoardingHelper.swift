//
//  LoadFundsOnBoardingHelper.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 17/6/21.
//

import Foundation

public enum LoadFundsOnBoardingHelper {
    private static let OnBoardingScreen = "com.apto.load.funds.onboarding.presented"
    public static func shouldPresentOnBoarding(userDefaults: UserDefaults = .standard) -> Bool {
        return userDefaults.bool(forKey: OnBoardingScreen) == false
    }

    public static func markAsPresented(userDefaults: UserDefaults = .standard) {
        userDefaults.set(true, forKey: OnBoardingScreen)
    }
}
