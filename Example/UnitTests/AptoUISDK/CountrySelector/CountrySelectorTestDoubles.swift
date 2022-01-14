//
// CountrySelectorTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
@testable import AptoUISDK
import Foundation

class CountrySelectorInteractorSpy: CountrySelectorInteractorProtocol {
    private(set) var fetchCountriesCalled = false
    func fetchCountries() -> [Country] {
        fetchCountriesCalled = true
        return []
    }
}

class CountrySelectorInteractorFake: CountrySelectorInteractorSpy {
    var countries: [Country] = []

    override func fetchCountries() -> [Country] {
        _ = super.fetchCountries()
        return countries
    }
}

class CountrySelectorPresenterSpy: CountrySelectorPresenterProtocol {
    let viewModel = CountrySelectorViewModel()
    var interactor: CountrySelectorInteractorProtocol?
    var router: CountrySelectorModuleProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var countrySelectedCalled = false
    private(set) var lastCountrySelected: Country?
    func countrySelected(_ country: Country) {
        countrySelectedCalled = true
        lastCountrySelected = country
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }
}

class CountrySelectorModuleSpy: UIModuleSpy, CountrySelectorModuleProtocol {
    var onCountrySelected: ((Country) -> Void)?

    private(set) var countrySelectedCalled = false
    private(set) var lastCountrySelected: Country?
    func countrySelected(_ country: Country) {
        countrySelectedCalled = true
        lastCountrySelected = country
    }
}
