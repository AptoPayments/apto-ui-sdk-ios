//
//  StorageLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 19/07/2018.
//
//

@testable import AptoSDK

class StorageLocatorFake: StorageLocatorProtocol {
  lazy var userStorageFake = UserStorageFake()
  func userStorage(transport: JSONTransport) -> UserStorageProtocol {
    return userStorageFake
  }

  lazy var configurationStorageFake = ConfigurationStorageFake()
  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol {
    return configurationStorageFake
  }

  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol {
    return CardApplicationsStorage(transport: transport)
  }

  lazy var financialAccountsStorageFake = FinancialAccountsStorageFake()
  func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol {
    return financialAccountsStorageFake
  }

  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol {
    return PushTokenStorage(transport: transport)
  }

  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol {
    return OauthStorage(transport: transport)
  }

  func notificationPreferencesStorage(transport: JSONTransport) -> NotificationPreferencesStorageProtocol {
    return NotificationPreferencesStorage(transport: transport)
  }

  lazy var userTokenStorageFake = UserTokenStorageFake()
  func userTokenStorage() -> UserTokenStorageProtocol {
    return userTokenStorageFake
  }

  lazy var featuresStorageSpy = FeaturesStorageSpy()
  func featuresStorage() -> FeaturesStorageProtocol {
    return featuresStorageSpy
  }

  func voIPStorage(transport: JSONTransport) -> VoIPStorageProtocol {
    return VoIPStorage(transport: transport)
  }

  func authenticatedLocalFileManager() -> LocalCacheFileManagerProtocol {
    return localCacheFileManagerFake
  }

  lazy var localCacheFileManagerFake = LocalCacheFileManager()
  func localCacheFileManager() -> LocalCacheFileManagerProtocol {
    return localCacheFileManagerFake
  }

  lazy var userPreferencesStorageFake = UserPreferencesStorageFake()
  func userPreferencesStorage() -> UserPreferencesStorageProtocol {
    return userPreferencesStorageFake
  }
  
  func paymentSourcesStorage(transport: JSONTransport) -> PaymentSourcesStorageProtocol {
    PaymentSourcesStorageFake()
  }
    
    lazy var agreementStorageSpy = AgreementStorageSpy()
    func achAccountAgreementStorage(transport: JSONTransport) -> AgreementStorageProtocol {
        return agreementStorageSpy
    }

    lazy var achAccountStorageSpy = ACHAccountStorageSpy()
    func achAccountStorage(transport: JSONTransport) -> ACHAccountStorageProtocol {
        return achAccountStorageSpy
    }
}
