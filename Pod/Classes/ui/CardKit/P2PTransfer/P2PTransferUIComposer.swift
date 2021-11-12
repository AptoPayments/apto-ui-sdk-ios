//
//  P2PTransferUIComposer.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 23/7/21.
//

import Foundation
import AptoSDK
import UIKit

struct P2PTransferUIComposer {
    public static func compose(with uiConfiguration: UIConfig,
                               platform: AptoPlatformProtocol,
                               projectConfig: ProjectConfiguration?) -> P2PTransferViewController {
        let viewModel = P2PTransferViewModel(loader: platform)
        let controller = P2PTransferViewController(uiConfiguration: uiConfiguration, viewModel: viewModel, projectConfiguration: projectConfig)
        controller.modalPresentationStyle = .formSheet
        return controller
    }

    public static func compose(with uiConfiguration: UIConfig,
                               platform: AptoPlatformProtocol,
                               transferModel model: P2PTransferModel,
                               cardId: String) -> P2PTransferFundsViewController {
        let viewModel = P2PTransferFundsViewModel(loader: platform, cardId: cardId)
        let controller = P2PTransferFundsViewController(uiConfiguration: uiConfiguration, viewModel: viewModel, transferModel: model)
        return controller
    }
    
    public static func composeSuccess(with uiConfiguration: UIConfig,
                                      transferResponse: P2PTransferResponse) -> P2PTransferResultViewController {
        let controller = P2PTransferResultViewController(uiConfiguration: uiConfiguration,
                                                         transferResponse: transferResponse)
        return controller
    }
}
