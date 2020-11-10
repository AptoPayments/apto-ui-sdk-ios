//
//  SystemServicesLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/10/2019.
//

import Foundation
@testable import AptoUISDK

class SystemServicesLocatorFake: SystemServicesLocatorProtocol {
  lazy var fileDownloaderFake = FileDownloaderFake()
  func fileDownloader(url: URL, localFilename: String) -> FileDownloader {
    return fileDownloaderFake
  }

  lazy var fileManagerFake = FileManagerFake()
  func fileManager(filename: String) -> FileManagerProtocol {
    return fileManagerFake
  }

  lazy var additionalFieldsSpy = CardAdditionalFieldsSpy()
  func cardAdditionalFields() -> CardAdditionalFieldsProtocol {
    additionalFieldsSpy
  }

  lazy var cardMetadataSpy = CardMetadataSpy()
  func cardMetadata() -> CardMetadataProtocol {
    cardMetadataSpy
  }

  lazy var userMetadataSpy = UserMetadataSpy()
  func userMetadata() -> UserMetadataProtocol {
    userMetadataSpy
  }

  lazy var dateProviderFake = DateProviderFake()
  func dateProvider() -> DateProviderProtocol {
    return dateProviderFake
  }

  lazy var authenticationManagerFake = AuthenticationManagerFake()
  func authenticationManager() -> AuthenticationManagerProtocol {
    return authenticationManagerFake
  }
}
