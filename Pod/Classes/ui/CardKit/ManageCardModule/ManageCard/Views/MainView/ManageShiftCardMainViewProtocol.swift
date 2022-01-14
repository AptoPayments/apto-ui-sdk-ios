//
// ManageCardMainViewProtocol.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-12.
//

import AptoSDK
import Foundation

protocol ManageCardMainViewDelegate: AnyObject {
    func cardTapped()
    func cardSettingsTapped()
    func balanceTapped()
    func needToUpdateUI(action: () -> Void, completion: @escaping () -> Void)
    func activatePhysicalCardTapped()
}

enum TopMessageViewType: Int, Equatable {
    case none
    case invalidBalance
    case noBalance
    case activatePhysicalCard
}

protocol CardPresentationProtocol {
    func set(card: Card?)
    func set(cardNetwork: CardNetwork?)
    func set(fundingSource: FundingSource?)
    func set(physicalCardActivationRequired: Bool?, showMessage: Bool)
    func setSpendable(amount: Amount?, nativeAmount: Amount?)
    func set(cardState: FinancialAccountState?)
    func set(cardStyle: CardStyle?)
    func set(activateCardFeatureEnabled: Bool?)
    func set(showInfo: Bool?)
    func scale(factor scaleFactor: CGFloat)
    func showSetCardPin(_ show: Bool)
}

typealias ManageCardMainViewProtocol = UIView & CardPresentationProtocol
