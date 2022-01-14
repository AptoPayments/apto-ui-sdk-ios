//
//  CardProductSelectorContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 15/05/2019.
//

import AptoSDK
import Foundation

protocol CardProductSelectorModuleProtocol: UIModuleProtocol {
    var onCardProductSelected: ((_ cardProduct: CardProductSummary) -> Void)? { get set }
}
