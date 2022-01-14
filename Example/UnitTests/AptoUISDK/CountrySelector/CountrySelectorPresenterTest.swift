//
// CountrySelectorPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class CountrySelectorPresenterTest: XCTestCase {
    private var sut: CountrySelectorPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = CountrySelectorModuleSpy(serviceLocator: ServiceLocatorFake())
    private let interactor = CountrySelectorInteractorFake()
    private let country = Country.defaultCountry

    override func setUp() {
        super.setUp()
        sut = CountrySelectorPresenter()
        sut.interactor = interactor
        sut.router = router
    }

    func testViewLoadedCallInteractor() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(interactor.fetchCountriesCalled)
    }

    func testCountriesReturnedUpdateViewModel() {
        // Given
        interactor.countries = [country]

        // When
        sut.viewLoaded()

        // Then
        XCTAssertEqual(interactor.countries, sut.viewModel.countries.value)
    }

    func testPresenterSortCountriesByName() {
        // Given
        let country1 = Country(isoCode: "US")
        let country2 = Country(isoCode: "CA")
        interactor.countries = [country1, country2]

        // When
        sut.viewLoaded()

        // Then
        let expectedCountries = [country2, country1]
        XCTAssertEqual(expectedCountries, sut.viewModel.countries.value)
    }

    func testCountrySelectedNotifyTheRouter() {
        // When
        sut.countrySelected(country)

        // Then
        XCTAssertTrue(router.countrySelectedCalled)
        XCTAssertEqual(country, router.lastCountrySelected)
    }

    func testCloseTappedCallRouter() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.closeCalled)
    }
}
