//
//  DirectDepositViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 27/1/21.
//

import AptoSDK

class DirectDepositViewController: ShiftViewController {
    private(set) lazy var mainView = DirectDepositView(uiconfig: uiConfiguration)
    private let loader: AptoPlatformProtocol
    private let analyticsManager: AnalyticsServiceProtocol
    private let cardId: String
    typealias CardProductsResult = Result<CardProduct, NSError>
    
    init(uiConfiguration: UIConfig, cardId: String, loader: AptoPlatformProtocol, analyticsManager: AnalyticsServiceProtocol) {
        self.loader = loader
        self.cardId = cardId
        self.analyticsManager = analyticsManager
        super.init(uiConfiguration: uiConfiguration)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        analyticsManager.track(event: .directDepositStart)
    }
    
    // MARK: Private methods
    private func load() {
        mainView.activityIndicator.startAnimating()
        mainView.alpha = 0
        loader
            .fetchCard(cardId,
                       forceRefresh: false,
                       retrieveBalances: false,
                       callback: { [weak self] cardResult in
                        switch cardResult {
                        case .success(let card):
                            if let productId = card.cardProductId {
                                self?
                                    .loader
                                    .fetchCardProduct(cardProductId: productId,
                                                      forceRefresh: false,
                                                      callback: { result in
                                                        switch result {
                                                        case .success(let cardProduct):
                                                            if let viewData = DirectDepositViewDataMapper.map(card: card, cardProduct: cardProduct) {
                                                                self?.mainView.configure(with: viewData)
                                                            }
                                                        case .failure(let error):
                                                            self?.show(error: error)
                                                        }
                                                        self?.hideActivityIndicator()
                                                      })
                            }
                        case .failure(let error):
                            self?.show(error: error)
                            self?.hideActivityIndicator()
                        }
                       })
    }
    
    private func hideActivityIndicator() {
        mainView.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.mainView.alpha = 1
        }
    }
}

public struct DirectDepositViewData {
    let accountDetails: BankAccountDetails
    let description: String
    let footer: String
}

struct DirectDepositViewDataMapper {
    private init() {}
    public static func map(card: Card, cardProduct: CardProduct) -> DirectDepositViewData? {
        guard let accountDetails = card.features?.bankAccount?.bankAccountDetails else { return nil }
        let description = "load_funds_direct_deposit_instructions_description".podLocalized().replace(["<<APP_NAME>>": cardProduct.name])
        let footer = "load_funds.direct_deposit.footer.description".podLocalized().replace(["<<APP_NAME>>": cardProduct.name])
        return DirectDepositViewData(accountDetails: accountDetails, description: description, footer: footer)
    }
}
