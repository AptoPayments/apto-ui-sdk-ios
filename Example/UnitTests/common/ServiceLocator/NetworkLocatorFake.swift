//
//  NetworkLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

@testable import AptoSDK

class NetworkLocatorFake: NetworkLocatorProtocol {
  lazy var networkManagerSpy: NetworkManagerSpy = NetworkManagerSpy()
  func networkManager(baseURL: URL?,
                      certPinningConfig: [String: [String: AnyObject]]?,
                      allowSelfSignedCertificate: Bool) -> NetworkManagerProtocol {
    return networkManagerSpy
  }

  lazy var jsonTransportFake = JSONTransportFake()
  func jsonTransport(environment: JSONTransportEnvironment,
                     baseUrlProvider: BaseURLProvider,
                     certPinningConfig: [String: [String: AnyObject]]?,
                     allowSelfSignedCertificate: Bool) -> JSONTransport {
    return jsonTransportFake
  }
}
