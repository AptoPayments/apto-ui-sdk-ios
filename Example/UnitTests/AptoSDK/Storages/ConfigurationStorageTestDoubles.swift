//
// ConfigurationStorageTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

@testable import AptoSDK
import Foundation

class ConfigurationStorageSpy: ConfigurationStorageProtocol {
    var cardOptions: CardOptions?

    private(set) var contextConfigurationCalled = false
    private(set) var lastContextConfigurationApiKey: String?
    private(set) var lastContextConfigurationForceRefresh: Bool?
    func contextConfiguration(_ apiKey: String, forceRefresh: Bool,
                              callback _: @escaping Result<ContextConfiguration, NSError>.Callback)
    {
        contextConfigurationCalled = true
        lastContextConfigurationApiKey = apiKey
        lastContextConfigurationForceRefresh = forceRefresh
    }

    func cardConfiguration(_: String, userToken _: String, forceRefresh _: Bool, cardProductId _: String,
                           callback _: @escaping Result<CardProduct, NSError>.Callback) {}

    func cardProducts(_: String, userToken _: String,
                      callback _: @escaping Result<[CardProductSummary], NSError>.Callback) {}

    private(set) var uiConfigCalled = false
    func uiConfig() -> UIConfig? {
        uiConfigCalled = true
        return ModelDataProvider.provider.uiConfig
    }
}

class ConfigurationStorageFake: ConfigurationStorageSpy {
    var nextContextConfigurationResult: Result<ContextConfiguration, NSError>?
    override func contextConfiguration(_ apiKey: String, forceRefresh: Bool,
                                       callback: @escaping Result<ContextConfiguration, NSError>.Callback)
    {
        super.contextConfiguration(apiKey, forceRefresh: forceRefresh, callback: callback)
        if let result = nextContextConfigurationResult {
            callback(result)
        }
    }
}
