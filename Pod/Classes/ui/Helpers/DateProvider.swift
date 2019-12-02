//
//  DateProvider.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

import Foundation

protocol DateProviderProtocol {
  func currentDate() -> Date
}

class DateProvider: DateProviderProtocol {
  func currentDate() -> Date {
    return Date()
  }
}
