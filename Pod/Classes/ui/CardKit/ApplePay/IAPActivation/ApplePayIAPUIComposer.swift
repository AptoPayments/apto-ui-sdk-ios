//
//  ApplePayIAPUIComposer.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 16/4/21.
//

import Foundation

import AptoSDK

public final class ApplePayIAPUIComposer {
    private init() {}
    public typealias IAPCompletion = (() -> Void)

    public static func composedWith(cardId: String,
                                    cardLoader: AptoPlatformProtocol,
                                    uiConfiguration: UIConfig,
                                    iapCompletion: IAPCompletion? = nil) -> ApplePayIAPViewController {
        let viewModel = ApplePayIAPViewModel(cardId: cardId, loader: cardLoader)
        let controller = ApplePayIAPViewController(viewModel: viewModel, uiConfiguration: UIConfig.default)
        controller.didFinishInAppProvisioning = { controller, pass, error in
            controller.dismiss(animated: true)
            iapCompletion?()
        }
        return controller
    }
}
