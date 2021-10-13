//
//  CardShippingStatus.swift
//  AptoSDK
//
//  Created by Evan Li on 9/17/21.
//

import Foundation
import AptoSDK

struct CardShippingStatusResult {
  let show: Bool
  let title: String?
  let subtitle: String?
}

class CardShippingStatus {
  
  public var overrideCurrentDate: Date? = nil
  
  func formatShippingStatus(orderedStatus: OrderedStatus, issuedAt: Date? ) -> CardShippingStatusResult {
    var showShipping = false
    var shippingTitle = ""
    var shippingSubtitle = ""
  
    if let issuedAt = issuedAt {
      var currentDate = Date.currentDate()
      if let override = self.overrideCurrentDate {
        currentDate = override
      }
      let daysSinceIssue = issuedAt.weekdaysBetween(endDate: currentDate )
      if (orderedStatus == .ordered && daysSinceIssue < 20 ) {
        showShipping = true
        switch daysSinceIssue {
          case 0..<2:
            shippingTitle = "card_settings.shipping.first.title".podLocalized()
            shippingSubtitle = "card_settings.shipping.first.description".podLocalized()
            break
          case 2..<4:
            shippingTitle = "card_settings.shipping.second.title".podLocalized()
            shippingSubtitle = "card_settings.shipping.second.description".podLocalized()
            break
          case 4..<8:
            shippingTitle = "card_settings.shipping.third.title".podLocalized()
            shippingSubtitle = "card_settings.shipping.third.description".podLocalized()
            break
          case 8..<14:
            shippingTitle = "card_settings.shipping.fourth.title".podLocalized()
            shippingSubtitle = "card_settings.shipping.fourth.description".podLocalized()
            break
          default:
            shippingTitle = "card_settings.shipping.fifth.title".podLocalized()
            shippingSubtitle = "card_settings.shipping.fifth.description".podLocalized()
            break
          }
      }
      
      let startDate = issuedAt.addBusinessDays(days: 7)
      let endDate = issuedAt.addBusinessDays(days: 10)
        
      let startDateString = startDate.format(dateFormat: "MMM d")
      let endDateString = endDate.format(dateFormat: "MMM d")
      
      shippingSubtitle = shippingSubtitle.replacingOccurrences(of: "<<MIN>>", with: startDateString)
      shippingSubtitle = shippingSubtitle.replacingOccurrences(of: "<<MAX>>", with: endDateString)
    }
    return CardShippingStatusResult(show: showShipping, title: shippingTitle, subtitle: shippingSubtitle)
  }
}
