//
//  AddMoneyAnimationController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 16/2/21.
//

import UIKit

final class AddMoneyAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction {
        case present
        case dismiss
    }

    var direction: Direction = .present
    private let addMoneyView: AddMoneyView

    init(with addMoneyView: AddMoneyView) {
        self.addMoneyView = addMoneyView
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval { 0.5 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch direction {
        case .present:
            present(using: transitionContext)
        case .dismiss:
            dismiss(using: transitionContext)
        }
    }

    private func present(using context: UIViewControllerContextTransitioning) {
        guard context.view(forKey: .to) != nil else {
            context.completeTransition(false)
            return
        }

        addMoneyView.present(in: context.containerView) { finish in
            context.completeTransition(finish)
        }
    }

    private func dismiss(using _: UIViewControllerContextTransitioning) {}
}
