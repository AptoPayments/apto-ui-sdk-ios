//
// CardProductSelectorModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import AptoSDK
import Foundation

class CardProductSelectorModule: UIModule, CardProductSelectorModuleProtocol {
    var onCardProductSelected: ((CardProductSummary) -> Void)?
    private var countries: Set<Country> = []
    private var cardProductsPerCountry: [Country: [CardProductSummary]] = [:]

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        showLoadingView()
        platform.fetchCardProducts { [weak self] result in
            self?.hideLoadingView()
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(cardProducts):
                guard !cardProducts.isEmpty else {
                    return completion(.failure(BackendError(code: .incorrectParameters)))
                }
                self?.handle(cardProducts: cardProducts, completion: completion)
            }
        }
    }

    override func close() {
        serviceLocator.analyticsManager.track(event: .cardProductSelectorCountrySelectorClosed)
        super.close()
    }

    private func handle(cardProducts: [CardProductSummary],
                        completion: @escaping Result<UIViewController, NSError>.Callback)
    {
        countries.removeAll()
        if cardProducts.count == 1 {
            selectCardProduct(cardProducts[0])
            return
        }
        cardProducts.forEach { cardProduct in
            cardProduct.countries?.forEach { country in
                countries.insert(country)
                var list = cardProductsPerCountry[country] ?? []
                list.append(cardProduct)
                cardProductsPerCountry[country] = list
            }
        }
        if countries.count < 2 {
            // If one or no countries select the first cardProduct returned
            selectCardProduct(cardProducts[0], country: countries.first)
            return
        }
        let module = serviceLocator.moduleLocator.countrySelectorModule(countries: Array(countries))
        module.onCountrySelected = handleCountry
        module.onClose = { [unowned self] _ in
            self.close()
        }
        serviceLocator.analyticsManager.track(event: .cardProductSelectorCountrySelectorShown)
        addChild(module: module, completion: completion)
    }

    private func selectCardProduct(_ cardProduct: CardProductSummary, country: Country? = nil) {
        var properties: [String: Any] = ["cardProductId": cardProduct.id]
        if let country = country {
            properties["countryCode"] = country.isoCode
        }
        serviceLocator.analyticsManager.track(event: .cardProductSelectorProductSelected, properties: properties)
        onCardProductSelected?(cardProduct)
    }

    private func handleCountry(_ country: Country) {
        guard let cardProducts = cardProductsPerCountry[country], !cardProducts.isEmpty else {
            fatalError("This should never happen")
        }
        selectCardProduct(cardProducts[0], country: country)
    }
}
