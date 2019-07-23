//
//  StorageLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 19/07/2018.
//
//

@testable import AptoSDK

class StorageLocatorFake: StorageLocatorProtocol {
  func userStorage(transport: JSONTransport) -> UserStorageProtocol {
    Swift.fatalError("userStorage(transport:) has not been implemented")
  }

  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol {
    Swift.fatalError("configurationStorage(transport:) has not been implemented")
  }

  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol {
    Swift.fatalError("cardApplicationsStorage(transport:) has not been implemented")
  }

  func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol {
    Swift.fatalError("financialAccountsStorage(transport:) has not been implemented")
  }

  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol {
    Swift.fatalError("pushTokenStorage(transport:) has not been implemented")
  }

  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol {
    Swift.fatalError("oauthStorage(transport:) has not been implemented")
  }

  func notificationPreferencesStorage(transport: JSONTransport) -> NotificationPreferencesStorageProtocol {
    Swift.fatalError("notificationPreferencesStorage(transport:) has not been implemented")
  }

  func userTokenStorage() -> UserTokenStorageProtocol {
    Swift.fatalError("userTokenStorage() has not been implemented")
  }

  func featuresStorage() -> FeaturesStorageProtocol {
    Swift.fatalError("featuresStorage() has not been implemented")
  }

  func voIPStorage(transport: JSONTransport) -> VoIPStorageProtocol {
    Swift.fatalError("voIpStorage(transport:) has not been implemented")
  }

  func authenticatedLocalFileManager() -> LocalCacheFileManagerProtocol {
    Swift.fatalError("authenticatedLocalFileManager() has not been implemented")
  }

  func localCacheFileManager() -> LocalCacheFileManagerProtocol {
    Swift.fatalError("localCacheFileManager() has not been implemented")
  }

  func userPreferencesStorage() -> UserPreferencesStorageProtocol {
    Swift.fatalError("userPreferencesStorage() has not been implemented")
  }
}
