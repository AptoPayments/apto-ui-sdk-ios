//
//  SystemServicesLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/10/2019.
//

@testable import AptoUISDK
import Foundation

class SystemServicesLocatorFake: SystemServicesLocatorProtocol {
    lazy var fileDownloaderFake = FileDownloaderFake()
    func fileDownloader(url _: URL, localFilename _: String) -> FileDownloader {
        return fileDownloaderFake
    }

    lazy var fileManagerFake = FileManagerFake()
    func fileManager(filename _: String) -> FileManagerProtocol {
        return fileManagerFake
    }

    lazy var additionalFieldsSpy = CardAdditionalFieldsSpy()
    func cardAdditionalFields() -> CardAdditionalFieldsProtocol {
        additionalFieldsSpy
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
