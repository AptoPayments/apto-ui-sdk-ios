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
}
