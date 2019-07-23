//
//  Custodian.swift
//  AptoUISDK
//
//  Created by Takeichi Kanzaki on 18/07/2019.
//

import Foundation
import AptoSDK

extension CustodianType {
  func logo() -> UIImage? {
    switch self {
    case .coinbase:
      return UIImage.imageFromPodBundle("coinbase_logo.png")
    case .uphold:
      return nil
    }
  }
}

extension Custodian {
  func custodianLogo() -> UIImage? {
    return custodianType.logo()
  }
}
