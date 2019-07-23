//
//  CountrySelectorContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 16/05/2019.
//

import Foundation
import AptoSDK
import Bond

protocol CountrySelectorModuleProtocol: UIModuleProtocol {
  var onCountrySelected: ((_ country: Country) -> ())? { get set }

  func countrySelected(_ country: Country)
}

protocol CountrySelectorInteractorProtocol {
  func fetchCountries() -> [Country]
}

class CountrySelectorViewModel {
  let countries: Observable<[Country]> = Observable([])
}

protocol CountrySelectorPresenterProtocol: class {
  var viewModel: CountrySelectorViewModel { get }
  var interactor: CountrySelectorInteractorProtocol? { get set }
  var router: CountrySelectorModuleProtocol? { get set }

  func viewLoaded()
  func countrySelected(_ country: Country)
  func closeTapped()
}
