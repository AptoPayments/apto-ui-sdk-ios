//
//  P2pTransferModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 6/9/21.
//

import AptoSDK
import Foundation

struct P2PTransferModel {
    let phone: PhoneNumber?
    let email: String?
    let cardholder: CardholderData?
}

enum P2PTransferModelMapper {
    public static func mapToCardConfig(_ model: P2PTransferModel, action: @escaping (() -> Void))
        -> CurrentCardConfig?
    {
        if let cardholder = model.cardholder,
           let firstname = cardholder.firstName,
           let lastname = cardholder.lastName
        {
            return CurrentCardConfig(title: "\(firstname) \(lastname)",
                                     icon: UIImage.imageFromPodBundle("credit_debit_card"),
                                     action: CurrentCardConfig
                                         .Action(title: "p2p_transfer.transfer_funds.add_amount.action.title"
                                             .podLocalized(), action: action))
        } else if let email = model.email {
            return CurrentCardConfig(title: email,
                                     icon: UIImage.imageFromPodBundle("credit_debit_card"),
                                     action: CurrentCardConfig
                                         .Action(title: "p2p_transfer.transfer_funds.add_amount.action.title"
                                             .podLocalized(), action: action))
        }
        return nil
    }
}
