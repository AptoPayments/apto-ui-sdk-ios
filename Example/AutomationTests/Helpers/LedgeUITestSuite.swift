//
//  AptoUITestSuite.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/10/2017.
//

import UIKit

extension AptoUITest {
    func resetSDK() {
        var counter = 0
        while counter < 10 {
            if SDKLauncherScreen(self).isScreenPresent() {
                return
            } else {
                let currentScreen = Screen(self)
                if currentScreen.previousAvailable() {
                    currentScreen.previous()
                } else if currentScreen.closeAvailable() {
                    currentScreen.close()
                }
                tester().wait(forTimeInterval: 0.1)
                counter = counter + 1
            }
        }

        tester().fail()
    } // end resetSDK

    func configure(teamKey: String?, projectKey: String?) {
        // Configure Team and Project keys
        SDKLauncherScreen(self)
            .waitForScreen()
            .openSettingsScreen()

        SDKSettingsScreen(self)
            .waitForScreen()
            .clearUserToken()
            .configure(teamKey: teamKey, projectKey: projectKey)
    } // end configure(teamKey, projectKey)
}
