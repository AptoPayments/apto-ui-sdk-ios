//
// CountrySelectorInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
import Foundation

class CountrySelectorInteractor: CountrySelectorInteractorProtocol {
    private let countries: [Country]

    init(countries: [Country]) {
        self.countries = countries
    }

    func fetchCountries() -> [Country] {
        return countries
    }
}
