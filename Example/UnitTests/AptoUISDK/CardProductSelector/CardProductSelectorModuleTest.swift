//
// CardProductSelectorModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class CardProductSelectorModuleTest: XCTestCase {
    private var sut: CardProductSelectorModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var platform = serviceLocator.platformFake
    private lazy var analyticsManager = serviceLocator.analyticsManagerSpy

    override func setUp() {
        super.setUp()
        sut = CardProductSelectorModule(serviceLocator: serviceLocator)
    }

    func testInitializeLoadCardProducts() {
        // When
        sut.initialize { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardProductsCalled)
    }

    func testCardProductsFailsCallbackFailure() {
        // Given
        var returnedResult: Result<UIViewController, NSError>?
        platform.nextFetchCardProductsResult = .failure(BackendError(code: .other))

        // When
        sut.initialize { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testCardProductsReturnOneProductCallCardProductSelected() {
        // Given
        var cardProductSelectedCalled = false
        sut.onCardProductSelected = { _ in
            cardProductSelectedCalled = true
        }
        platform.nextFetchCardProductsResult = .success([CardProductSummary(id: "id", name: "name", countries: nil)])

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertTrue(cardProductSelectedCalled)
    }

    func testCardProductsReturnMoreThanAProductAllWithSameCountryReturnFirstCardProduct() {
        // Given
        var returnedCardProduct: CardProductSummary?
        sut.onCardProductSelected = { cardProduct in
            returnedCardProduct = cardProduct
        }
        let cardProducts = [
            CardProductSummary(id: "id1", name: "name1", countries: [Country.defaultCountry]),
            CardProductSummary(id: "id2", name: "name2", countries: [Country.defaultCountry]),
        ]
        platform.nextFetchCardProductsResult = .success(cardProducts)

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertEqual(cardProducts[0], returnedCardProduct)
    }

    func testCardProductsReturnMoreThanACardProductWithDifferentCountriesShowCountrySelector() {
        // Given
        let cardProducts = [
            CardProductSummary(id: "id1", name: "name1", countries: [Country(isoCode: "US")]),
            CardProductSummary(id: "id2", name: "name2", countries: [Country(isoCode: "UK")]),
        ]
        platform.nextFetchCardProductsResult = .success(cardProducts)

        // When
        sut.initialize { _ in }

        // Then
        let countrySelectorModule = serviceLocator.moduleLocatorFake.countrySelectorModuleSpy
        XCTAssertTrue(countrySelectorModule.initializeCalled)
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.cardProductSelectorCountrySelectorShown, analyticsManager.lastEvent)
    }

    func testCountrySelectedReturnAssociatedCardProduct() {
        // Given
        var returnedCardProduct: CardProductSummary?
        sut.onCardProductSelected = { cardProduct in
            returnedCardProduct = cardProduct
        }
        let selectedCountry = Country(isoCode: "UK")
        let cardProducts = [
            CardProductSummary(id: "id1", name: "name1", countries: [Country(isoCode: "US")]),
            CardProductSummary(id: "id2", name: "name2", countries: [selectedCountry]),
        ]
        platform.nextFetchCardProductsResult = .success(cardProducts)
        sut.initialize { _ in }
        let countrySelectorModule = serviceLocator.moduleLocatorFake.countrySelectorModuleSpy

        // When
        countrySelectorModule.onCountrySelected?(selectedCountry)

        // Then
        XCTAssertEqual(cardProducts[1], returnedCardProduct)
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.cardProductSelectorProductSelected, analyticsManager.lastEvent)
        XCTAssertNotNil(analyticsManager.lastProperties)
    }

    func testCloseCalledTrackEvent() {
        // When
        sut.close()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.cardProductSelectorCountrySelectorClosed, analyticsManager.lastEvent)
    }
}
