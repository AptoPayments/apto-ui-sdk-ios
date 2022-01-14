//
//  Transaction.swift
//  AptoUISDK
//
//  Created by Takeichi Kanzaki on 18/07/2019.
//

import AptoSDK
import Foundation

extension MCCIcon {
    func image() -> UIImage? { // swiftlint:disable:this cyclomatic_complexity
        switch self {
        case .plane:
            return UIImage.imageFromPodBundle("mcc_flights")
        case .car:
            return UIImage.imageFromPodBundle("mcc_car")
        case .glass:
            return UIImage.imageFromPodBundle("mcc_alcohol")
        case .finance:
            return UIImage.imageFromPodBundle("mcc_withdraw")
        case .food:
            return UIImage.imageFromPodBundle("mcc_food")
        case .gas:
            return UIImage.imageFromPodBundle("mcc_fuel")
        case .bed:
            return UIImage.imageFromPodBundle("mcc_hotel")
        case .medical:
            return UIImage.imageFromPodBundle("mcc_medicine")
        case .camera:
            return UIImage.imageFromPodBundle("mcc_other")
        case .card:
            return UIImage.imageFromPodBundle("mcc_bank_card")
        case .cart:
            return UIImage.imageFromPodBundle("mcc_purchases")
        case .road:
            return UIImage.imageFromPodBundle("mcc_toll_road")
        case .other:
            return UIImage.imageFromPodBundle("mcc_other")
        }
    }
}

extension MCC {
    func image() -> UIImage? {
        return icon.image()
    }
}
