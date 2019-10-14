//
//  SystemServicesLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/10/2019.
//

import Foundation

class SystemServicesLocator: SystemServicesLocatorProtocol {
  func fileDownloader(url: URL, localFilename: String) -> FileDownloader {
    return FileDownloaderImpl(url: url, localFilename: localFilename)
  }
}
