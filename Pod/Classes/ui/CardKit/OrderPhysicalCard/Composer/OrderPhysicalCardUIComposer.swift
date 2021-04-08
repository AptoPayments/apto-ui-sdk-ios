//
//  OrderPhysicalCardUIComposer.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/3/21.
//

import Foundation
import AptoSDK

final class OrderPhysicalCardUIComposer {
    private init() {}
    public typealias OrderedCompletion = (() -> Void)
    public typealias CardConfigErrorCompletion = ((NSError) -> Void)

    public static func composedWith(card: Card,
                                    cardLoader: AptoPlatformProtocol,
                                    analyticsManager: AnalyticsServiceProtocol,
                                    uiConfiguration: UIConfig,
                                    cardOrderedCompletion: OrderedCompletion? = nil,
                                    cardConfigErrorCompletion: CardConfigErrorCompletion? = nil) -> OrderPhysicalCardViewController {
        let viewModel = OrderPhysicalCardViewModel(card: card, loader: cardLoader, analyticsManager: analyticsManager)
        let controller = OrderPhysicalCardViewController(uiConfiguration: UIConfig.default, viewModel: viewModel)
        controller.cardOrderedCompletion = cardOrderedCompletion
        controller.cardConfigErrorCompletion = cardConfigErrorCompletion
        return controller
    }
}
