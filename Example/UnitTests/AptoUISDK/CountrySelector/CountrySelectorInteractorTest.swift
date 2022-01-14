//
// CountrySelectorInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class CountrySelectorInteractorTest: XCTestCase {
    private var sut: CountrySelectorInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let countries = [Country.defaultCountry]

    override func setUp() {
        super.setUp()
        sut = CountrySelectorInteractor(countries: countries)
    }

    func testFetchCountriesReturnInitValue() {
        // When
        let countries = sut.fetchCountries()

        // Then
        XCTAssertEqual(self.countries, countries)
    }
}
