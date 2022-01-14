//
//  CardSettingsInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import AptoSDK
import Foundation

class CardSettingsInteractor: CardSettingsInteractorProtocol {
    private let platform: AptoPlatformProtocol

    init(platform: AptoPlatformProtocol) {
        self.platform = platform
    }

    func isShowDetailedCardActivityEnabled() -> Bool {
        return platform.isShowDetailedCardActivityEnabled()
    }

    func setShowDetailedCardActivityEnabled(_ isEnabled: Bool) {
        platform.setShowDetailedCardActivityEnabled(isEnabled)
    }
}
