//
//  NetworkLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

@testable import AptoSDK

class NetworkLocatorFake: NetworkLocatorProtocol {
    lazy var networkManagerSpy = NetworkManagerSpy()
    func networkManager(baseURL _: URL?,
                        certPinningConfig _: [String: [String: AnyObject]]?,
                        allowSelfSignedCertificate _: Bool) -> NetworkManagerProtocol
    {
        return networkManagerSpy
    }

    lazy var jsonTransportFake = JSONTransportFake()
    func jsonTransport(environment _: JSONTransportEnvironment,
                       baseUrlProvider _: BaseURLProvider,
                       certPinningConfig _: [String: [String: AnyObject]]?,
                       allowSelfSignedCertificate _: Bool) -> JSONTransport
    {
        return jsonTransportFake
    }
}
