import AptoSDK
import Bond
import ReactiveKit

private typealias ViewModel = PassCodeOnboardingViewModelInput &
    PassCodeOnboardingViewModelOutput &
    PassCodeOnboardingViewModelType

final class PassCodeOnboardingViewModel: ViewModel {
    var input: PassCodeOnboardingViewModelInput { self }
    var output: PassCodeOnboardingViewModelOutput { self }

    var navigator: PassCodeOnboardingNavigatorType?

    private let card: Card
    private let apto: AptoPlatformProtocol

    init(apto: AptoPlatformProtocol = AptoPlatform.defaultManager(), card: Card) {
        self.card = card
        self.apto = apto
    }

    // MARK: - Output

    var state = Observable<PassCodeOnboardingViewState>(.idle)
    var moduleState = Observable<PassCodeModuleState>(.idle)
    var nextButtonEnabled = Observable<Bool>(false)

    // MARK: - Input

    func didTapOnSetPassCode() {
        if card.features?.passCode?.verificationRequired == true {
            state.send(.loading)
            apto.startPrimaryVerification { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.state.send(.error(error))
                case let .success(verification):
                    self?.state.send(.loaded(verification))
                    switch verification.verificationType {
                    case .phoneNumber:
                        self?.navigator?
                            .navigateToVerifyPhone(verificationType: .verification(verification)) { module, verification in
                                self?.navigateToSetPassCode(verification: verification, module: module)
                            }
                    case .email:
                        self?.navigator?
                            .navigateToVerifyEmail(verificationType: .verification(verification)) { module, verification in
                                self?.navigateToSetPassCode(verification: verification, module: module)
                            }
                    default:
                        break
                    }
                }
            }
        } else {
            navigateToSetPassCode()
        }
    }

    private func navigateToSetPassCode(verification: Verification? = nil, module: UIModule? = nil) {
        navigator?.navigateToSetPassCode(card: card, verification: verification, module: module) { [weak self] in
            self?.navigator?.close {
                self?.moduleState.send(.finished)
            }
        }
    }
}
