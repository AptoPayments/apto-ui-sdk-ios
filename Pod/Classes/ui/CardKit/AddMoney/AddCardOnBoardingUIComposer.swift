//
//  AddCardOnBoardingUIComposer.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 23/6/21.
//

import AptoSDK
import Foundation

struct AddCardOnBoardingUIComposer {
    public static func compose(with card: Card,
                               extraContent _: ExtraContent?,
                               platform: AptoPlatformProtocol,
                               actionCompletion: @escaping () -> Void,
                               closeCompletion: @escaping (UIViewController) -> Void)
        -> AddCardOnboardingViewController
    {
        let viewModel = AddCardOnboardingViewModel(cardId: card.accountId, loader: platform)
        let controller = AddCardOnboardingViewController(uiConfiguration: UIConfig.default, viewModel: viewModel)
        controller.modalPresentationStyle = .formSheet
        controller.actionButtonCompletion = actionCompletion
        controller.closeButtonCompletion = closeCompletion
        return controller
    }
}
