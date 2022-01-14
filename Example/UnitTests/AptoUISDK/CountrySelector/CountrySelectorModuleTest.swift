//
// CountrySelectorModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class CountrySelectorModuleTest: XCTestCase {
    private var sut: CountrySelectorModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let countries = [Country.defaultCountry]
    private lazy var presenter = serviceLocator.presenterLocatorFake.countrySelectorPresenterSpy

    override func setUp() {
        super.setUp()
        sut = CountrySelectorModule(serviceLocator: serviceLocator, countries: countries)
    }

    func testInitializeSetupPresenter() {
        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.router)
    }

    func testInitializeCallbackSuccess() {
        // Given
        var returnedResult: Result<UIViewController, NSError>?

        // When
        sut.initialize { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testCountrySelectedCallOnCountrySelected() {
        // Given
        var onCountrySelectedCalled = false
        sut.onCountrySelected = { _ in
            onCountrySelectedCalled = true
        }

        // When
        sut.countrySelected(countries[0])

        // Then
        XCTAssertTrue(onCountrySelectedCalled)
    }
}
