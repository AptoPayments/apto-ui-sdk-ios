//
//  CardModuleLaunchOptions.swift
//  AptoUISDK
//
//  Created by Ivan Oliver Martínez on 04/11/2020.
//

import Foundation
import AptoSDK

@objc public enum AptoUISDKMode: Int {
  case standalone
  case embedded
}

enum CardModuleInitialFlow {
  case newCardApplication
  case manageCard(cardId: String)
  case fullSDK
}

struct CardModuleLaunchOptions {
  let mode: AptoUISDKMode
  let initialUserData: DataPointList?
  let userMetadata: String?
  let cardMetadata: String?
  let googleMapsApiKey: String?
  let cardOptions: CardOptions?
  let initialFlow: CardModuleInitialFlow
}
