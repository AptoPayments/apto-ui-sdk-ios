//
//  ApplePayIAPViewControllerTests.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 15/4/21.
//

import AptoSDK
import SnapKit
import PassKit

final class ApplePayIAPViewController: ShiftViewController {
    var onCompletion: (() -> Void)?
    private let viewModel: ApplePayIAPViewModel
    var didFinishInAppProvisioning: ((PKAddPaymentPassViewController, PKPaymentPass?, Error?) -> Void)?
    
    init(viewModel: ApplePayIAPViewModel, uiConfiguration: UIConfig) {
        self.viewModel = viewModel
        super.init(uiConfiguration: uiConfiguration)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        setupBindings()
        viewModel.loadCard()
    }
    
    private func setupBindings() {
        viewModel.onCardFetched = { [weak self] card in            
            guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
                self?.show(error: BackendError(code: .incorrectParameters))
                return
            }
            configuration.cardholderName = card.cardHolder
            configuration.primaryAccountSuffix = card.lastFourDigits
            
            guard let paymentPassViewController = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: self) else {
                self?.show(error: BackendError(code: .undefinedError))
                return
            }
            self?.addChild(paymentPassViewController)
            self?.view.addSubview(paymentPassViewController.view)
            paymentPassViewController.didMove(toParent: self)
        }
    }
    
    override func closeTapped() {
        dismiss(animated: true)
    }
}

extension ApplePayIAPViewController: PKAddPaymentPassViewControllerDelegate {
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController,
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
    
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        didFinishInAppProvisioning?(controller, pass, error)
    }
}
