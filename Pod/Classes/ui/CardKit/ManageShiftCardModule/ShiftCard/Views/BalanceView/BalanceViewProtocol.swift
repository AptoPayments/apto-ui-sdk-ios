//
//  BalancePresentationProtocol.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 11/12/2018.
//

import Foundation
import AptoSDK

protocol BalancePresentationProtocol {
  func set(fundingSource: FundingSource)
  func set(spendableToday: Amount?, nativeSpendableToday: Amount?)
  func set(imageURL: String?)
  func scale(factor scaleFactor: CGFloat)
}

typealias BalanceViewProtocol = UIView & BalancePresentationProtocol
