//
//  SystemServicesLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/10/2019.
//

import Foundation

class SystemServicesLocator: SystemServicesLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fileDownloader(url: URL, localFilename: String) -> FileDownloader {
    return FileDownloaderImpl(url: url, localFilename: localFilename)
  }

  func fileManager(filename: String) -> FileManagerProtocol {
    return FileManagerImpl(filename: filename)
  }

  func dateProvider() -> DateProviderProtocol {
    return DateProvider()
  }

  func cardAdditionalFields() -> CardAdditionalFieldsProtocol {
    CardAdditionalFields.shared
  }
  
  func cardMetadata() -> CardMetadataProtocol {
    CardMetadata.shared
  }

  func userMetadata() -> UserMetadataProtocol {
    UserMetadata.shared
  }

  private var _authenticationManager: AuthenticationManagerProtocol?
  func authenticationManager() -> AuthenticationManagerProtocol {
    if let manager = _authenticationManager {
      return manager
    }
    let authManager = AuthenticationManager(fileManager: fileManager(filename: "code.dat"),
                                            dateProvider: dateProvider(), aptoPlatform: serviceLocator.platform,
                                            authenticator: Authenticator(serviceLocator: serviceLocator))
    _authenticationManager = authManager
    return authManager
  }
}
