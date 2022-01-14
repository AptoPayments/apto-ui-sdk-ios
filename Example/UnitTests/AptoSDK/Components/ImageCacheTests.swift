//
//  ImageCacheTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 25/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import AptoUISDK
import XCTest

class ImageCacheTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_defaultCache_createsImageCacheInstance() throws {
        let sut = makeSUT()
        XCTAssertNotNil(sut)
    }

    func test_imageWithURL_completesWithImage() {
        let imageData = makeImageData(withColor: .red)
        URLProtocolStub.stub(data: imageData, response: nil, error: nil)
        let sut = makeSUT()

        let exp = expectation(description: "Waiting for completion")
        var receivedResult: Result<UIImage, NSError>!

        sut.imageWithUrl(URL(string: "http://valid-url.com")!) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        switch receivedResult {
        case let .success(image):
            XCTAssertNotNil(image)
        default:
            XCTFail("Expected success got fail")
        }
    }

    func makeImageData(withColor color: UIColor) -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }

    private func makeSUT() -> ImageCache {
        let sut = ImageCache.shared
        return sut
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }

        override class func canInit(with _: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
