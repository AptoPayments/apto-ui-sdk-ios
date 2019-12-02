//
//  DateProviderFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

@testable import AptoUISDK

class DateProviderFake: DateProviderProtocol {
  var nextDateToProvide = Date()
  func currentDate() -> Date {
    return nextDateToProvide
  }
}
