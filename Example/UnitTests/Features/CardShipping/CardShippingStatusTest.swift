//
//  CardShippingStatusTest.swift
//  UnitTests
//
//  Created by Evan Li on 9/17/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

@testable import AptoUISDK
@testable import AptoSDK

final class CardShippingStatusTest: XCTestCase {
  
  func test_add_business_days() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoDate = "2021-09-17T10:00:00+0000"
    let date = dateFormatter.date(from:isoDate)!
    
    let isoNextDate = "2021-09-28T10:00:00+0000"
    let expectedDate = dateFormatter.date(from:isoNextDate)!
    
    let nextDate = date.addBusinessDays(days: 7)
  
    XCTAssertEqual(nextDate, expectedDate)
  }
  
  func test_validate_order_status() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-09-21T10:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!
    
    let orderedStatus: OrderedStatus = OrderedStatus.ordered
    
    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.show, true)
  }

  func test_not_validate_order_status() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-09-21T10:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!
    
    let orderedStatus: OrderedStatus = OrderedStatus.notApplicable
    
    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.show, false)
  }
  
  func test_days_calculator_negative_1_day() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-08-31T10:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let daysSinceIssue = issuedAt.weekdaysBetween(endDate: currentDate )
    print(daysSinceIssue)
    
    XCTAssertEqual(daysSinceIssue, -1)
  }
  
  func test_days_calculator_0_day() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-09-01T10:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let daysSinceIssue = issuedAt.weekdaysBetween(endDate: currentDate )
    print(daysSinceIssue)
    
    XCTAssertEqual(daysSinceIssue, 0)
  }
  
  func test_days_calculator_1_day() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-09-02T01:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let daysSinceIssue = issuedAt.weekdaysBetween(endDate: currentDate )
    print(daysSinceIssue)
    
    XCTAssertEqual(daysSinceIssue, 1)
  }
  
  func test_days_calculator_2_day() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-09-03T01:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let daysSinceIssue = issuedAt.weekdaysBetween(endDate: currentDate )
    print(daysSinceIssue)
    
    XCTAssertEqual(daysSinceIssue, 2)
  }
  
  func test_text_0_day() throws {
    let dateFormatter = ISO8601DateFormatter()
    
    let isoCurrentDate = "2021-09-01T12:00:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!
    
    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered
    
    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card was ordered")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "It should arrive between Sep 10 and Sep 15")
  }
  
  func test_text_1_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-02T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card was ordered")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "It should arrive between Sep 10 and Sep 15")
  }

  func test_text_2_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-03T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Cards typically ship out now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Yours should arrive between Sep 10 and Sep 15")
  }

  func test_text_3_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-06T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Cards typically ship out now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Yours should arrive between Sep 10 and Sep 15")
  }

  func test_text_4_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-07T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Cards are typically in transit now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Yours should arrive between Sep 10 and Sep 15")
  }

  func test_text_5_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-08T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Cards are typically in transit now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Yours should arrive between Sep 10 and Sep 15")
  }

  func test_text_6_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-09T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Cards are typically in transit now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Yours should arrive between Sep 10 and Sep 15")
  }

  func test_text_7_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-10T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Cards are typically in transit now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Yours should arrive between Sep 10 and Sep 15")
  }

  func test_text_8_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-13T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should be arriving soon")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Estimated delivery is between Sep 10 and Sep 15")
  }

  func test_text_9_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-14T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should be arriving soon")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Estimated delivery is between Sep 10 and Sep 15")
  }

  func test_text_10_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-15T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should be arriving soon")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Estimated delivery is between Sep 10 and Sep 15")
  }

  func test_text_11_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-16T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should be arriving soon")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Estimated delivery is between Sep 10 and Sep 15")
  }

  func test_text_12_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-17T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should be arriving soon")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Estimated delivery is between Sep 10 and Sep 15")
  }

  func test_text_13_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-18T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should be arriving soon")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Estimated delivery is between Sep 10 and Sep 15")
  }

  func test_text_17_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-24T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.title, "Your card should have arrived by now")
    XCTAssertEqual(cardShippingStatusResult.subtitle, "Please contact support if you haven't received it.")
  }

  func test_text_22_day() throws {
    let dateFormatter = ISO8601DateFormatter()

    let isoCurrentDate = "2021-09-30T10:01:00+0000"
    let currentDate = dateFormatter.date(from:isoCurrentDate)!

    let isoIssuedAt = "2021-09-01T10:00:00+0000"
    let issuedAt = dateFormatter.date(from:isoIssuedAt)!

    let orderedStatus: OrderedStatus = OrderedStatus.ordered

    let cardShippingStatus = CardShippingStatus()
    cardShippingStatus.overrideCurrentDate = currentDate
    let cardShippingStatusResult = cardShippingStatus.formatShippingStatus(orderedStatus: orderedStatus, issuedAt: issuedAt)
    
    XCTAssertEqual(cardShippingStatusResult.show, false)
  }
}
