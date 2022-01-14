//
//  EnableCardAction.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/03/2018.
//

import AptoSDK
import UIKit

class DisableCardAction {
    private let platform: AptoPlatformProtocol
    private let card: Card
    private let uiConfig: UIConfig

    init(platform: AptoPlatformProtocol, card: Card, uiConfig: UIConfig) {
        self.platform = platform
        self.card = card
        self.uiConfig = uiConfig
    }

    func run(callback: @escaping Result<Card, NSError>.Callback) {
        let okTitle = "card_settings.settings.confirm_lock_card.ok_button".podLocalized()
        let cancelTitle = "card_settings.settings.confirm_lock_card.cancel_button".podLocalized()
        UIAlertController.confirm(title: "card_settings.settings.confirm_lock_card.title".podLocalized(),
                                  message: "card_settings.settings.confirm_lock_card.message".podLocalized(),
                                  okTitle: okTitle, cancelTitle: cancelTitle) { [unowned self] action in
            guard action.title == okTitle else {
                return callback(.failure(ServiceError(code: .aborted)))
            }
            UIApplication.topViewController()?.showLoadingSpinner(tintColor: self.uiConfig.uiPrimaryColor)
            self.platform.lockCard(self.card.accountId) { result in
                UIApplication.topViewController()?.hideLoadingSpinner()
                switch result {
                case let .failure(error):
                    callback(.failure(error))
                case let .success(card):
                    callback(.success(card))
                }
            }
        }
    }
}
