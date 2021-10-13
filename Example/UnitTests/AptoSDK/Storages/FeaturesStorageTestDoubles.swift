//
//  FeaturesStorageTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/08/2019.
//

import Foundation
@testable import AptoSDK

class FeaturesStorageSpy: FeaturesStorage {
  private(set) var updateCalled = false
  override func update(features: [FeatureKey: Bool]) {
    updateCalled = true
    super.update(features: features)
  }

  private(set) var isFeatureEnabledCalled = false
  override func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool {
    isFeatureEnabledCalled = true
    return super.isFeatureEnabled(featureKey)
  }
}
