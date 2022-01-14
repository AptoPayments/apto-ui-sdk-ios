//
// CountrySelectorPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
import Foundation

class CountrySelectorPresenter: CountrySelectorPresenterProtocol {
    let viewModel = CountrySelectorViewModel()
    var interactor: CountrySelectorInteractorProtocol?
    var router: CountrySelectorModuleProtocol?

    func viewLoaded() {
        if let countries = interactor?.fetchCountries() {
            viewModel.countries.send(countries.sorted { $0.name < $1.name })
        }
    }

    func countrySelected(_ country: Country) {
        router?.countrySelected(country)
    }

    func closeTapped() {
        router?.close()
    }
}
