//
//  SystemServicesLocatorProtocol.swift
//  AptoUISDK
//
//  Created by Takeichi Kanzaki on 11/10/2019.
//

import Foundation

protocol FileDownloaderProvider {
  func fileDownloader(url: URL, localFilename: String) -> FileDownloader
}

protocol SystemServicesLocatorProtocol: FileDownloaderProvider {
}
