//
// ConfigurationStorageTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

import Foundation
@testable import AptoSDK

class ConfigurationStorageSpy: ConfigurationStorageProtocol {
  var cardOptions: CardOptions?

  private(set) var contextConfigurationCalled = false
  private(set) var lastContextConfigurationApiKey: String?
  private(set) var lastContextConfigurationForceRefresh: Bool?
  func contextConfiguration(_ apiKey: String, forceRefresh: Bool,
                            callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    contextConfigurationCalled = true
    lastContextConfigurationApiKey = apiKey
    lastContextConfigurationForceRefresh = forceRefresh
  }

  func cardConfiguration(_ apiKey: String, userToken: String, forceRefresh: Bool, cardProductId: String,
                         callback: @escaping Result<CardProduct, NSError>.Callback) {

  }

  func cardProducts(_ apiKey: String, userToken: String,
                    callback: @escaping Result<[CardProductSummary], NSError>.Callback) {

  }

  private(set) var uiConfigCalled = false
  func uiConfig() -> UIConfig? {
    uiConfigCalled = true
    return ModelDataProvider.provider.uiConfig
  }
}

class ConfigurationStorageFake: ConfigurationStorageSpy {
  var nextContextConfigurationResult: Result<ContextConfiguration, NSError>?
  override func contextConfiguration(_ apiKey: String, forceRefresh: Bool,
                                     callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    super.contextConfiguration(apiKey, forceRefresh: forceRefresh, callback: callback)
    if let result = nextContextConfigurationResult {
      callback(result)
    }
  }
}
