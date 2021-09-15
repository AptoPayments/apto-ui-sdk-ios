//
//  ApplePayIAPViewControllerTests.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 15/4/21.
//

import AptoSDK
import SnapKit
import PassKit

public final class ApplePayIAPViewController: UIViewController {
    var onCompletion: (() -> Void)?
    private let viewModel: ApplePayIAPViewModel
    var didFinishInAppProvisioning: ((PKAddPaymentPassViewController, PKPaymentPass?, Error?) -> Void)?
    private let uiConfig: UIConfig
    
    init(viewModel: ApplePayIAPViewModel, uiConfiguration: UIConfig) {
        self.viewModel = viewModel
        self.uiConfig = uiConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        setupBindings()
        viewModel.loadCard()
    }
    
    private func setupBindings() {
        viewModel.onCardFetched = { [weak self] card in
            guard let self = self else { return }
            guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
                AlertDialog.showToast(to: self, error: BackendError(code: .incorrectParameters), uiConfig: self.uiConfig)
                return
            }
            configuration.cardholderName = card.cardHolder
            configuration.primaryAccountSuffix = card.lastFourDigits
            
            guard let paymentPassViewController = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: self) else {
                AlertDialog.showToast(to: self, error: BackendError(code: .undefinedError), uiConfig: self.uiConfig)
                return
            }
            self.addChild(paymentPassViewController)
            self.view.addSubview(paymentPassViewController.view)
            paymentPassViewController.didMove(toParent: self)
        }
    }
    
    override func closeTapped() {
        dismiss(animated: true)
    }
}

extension ApplePayIAPViewController: PKAddPaymentPassViewControllerDelegate {
    public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController,
                                      generateRequestWithCertificateChain certificates: [Data],
                                      nonce: Data, nonceSignature: Data,
                                      completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        viewModel.sendRequestData(certificates: certificates, nonce: nonce, nonceSignature: nonceSignature) { issuerResponse in
            let request = PKAddPaymentPassRequest()
            request.activationData = issuerResponse.activationData
            request.ephemeralPublicKey = issuerResponse.ephemeralPublicKey
            request.encryptedPassData = issuerResponse.encryptedPassData
            handler(request)
        }
    }
    
    public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        didFinishInAppProvisioning?(controller, pass, error)
    }
}
