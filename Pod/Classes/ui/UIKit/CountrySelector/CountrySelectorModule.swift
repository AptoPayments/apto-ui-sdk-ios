//
// CountrySelectorModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import Foundation
import AptoSDK

class CountrySelectorModule: UIModule, CountrySelectorModuleProtocol {
  private let countries: [Country]
  private var presenter: CountrySelectorPresenterProtocol?

  var onCountrySelected: ((_ country: Country) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, countries: [Country]) {
    self.countries = countries
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  private func buildViewController() -> ShiftViewController {
    let interactor = serviceLocator.interactorLocator.countrySelectorInteractor(countries: countries)
    let presenter = serviceLocator.presenterLocator.countrySelectorPresenter()
    presenter.interactor = interactor
    presenter.router = self
    self.presenter = presenter
    return serviceLocator.viewLocator.countrySelectorView(presenter: presenter)
  }

  func countrySelected(_ country: Country) {
    onCountrySelected?(country)
  }
}
