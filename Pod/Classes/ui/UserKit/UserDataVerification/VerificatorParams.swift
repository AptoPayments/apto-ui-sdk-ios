//
//  VerificatorParams.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 27/02/2018.
//

import Foundation
import AptoSDK

public enum VerificationParams<D: DataPoint, V: Verification> {

  case datapoint(D)
  case verification(V)

  init(dataPoint: D) {
    self = .datapoint(dataPoint)
  }

  init(verification: V) {
    self = .verification(verification)
  }

  public var dataPoint: D? {
    guard case .datapoint(let dataPoint) = self else {
      return nil
    }
    return dataPoint
  }

  public var verification: V? {
    guard case .verification(let verification) = self else {
      return nil
    }
    return verification
  }

}
