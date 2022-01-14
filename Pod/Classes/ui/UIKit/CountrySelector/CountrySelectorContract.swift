//
//  CountrySelectorContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
import Bond
import Foundation

protocol CountrySelectorModuleProtocol: UIModuleProtocol {
    var onCountrySelected: ((_ country: Country) -> Void)? { get set }

    func countrySelected(_ country: Country)
}

protocol CountrySelectorInteractorProtocol {
    func fetchCountries() -> [Country]
}

class CountrySelectorViewModel {
    let countries: Observable<[Country]> = Observable([])
}

protocol CountrySelectorPresenterProtocol: AnyObject {
    var viewModel: CountrySelectorViewModel { get }
    var interactor: CountrySelectorInteractorProtocol? { get set }
    var router: CountrySelectorModuleProtocol? { get set }

    func viewLoaded()
    func countrySelected(_ country: Country)
    func closeTapped()
}
