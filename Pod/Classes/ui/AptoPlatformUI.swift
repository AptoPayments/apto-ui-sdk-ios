//
// AptoPlatformUI.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 12/07/2019.
//

import Foundation
import AptoSDK

// Extensions do not allow properties, instead of getting crazy with associated objects we create private propeties.
// This properties are made lazy by the compiler.
private var _initialModule: UIModuleProtocol?
private weak var _uiDelegate: AptoPlatformUIDelegate?
private let lockingQueue = DispatchQueue(label: "com.aptotpayments.ios.sdk.locking")
private var isPresentingNetworkNotReachable = false
private var fontRegistered = false
private let queue = DispatchQueue(label: "com.aptopayments.sdk.register.fonts")
private var _googleMapsApiKey: String?
private let serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared

extension AptoPlatformProtocol {
  var googleMapsApiKey: String? {
    return _googleMapsApiKey
  }
}

extension AptoPlatform {
  // MARK: UI platform initialization
  var initialModule: UIModuleProtocol? {
    get {
      return _initialModule
    }
    set {
      _initialModule = newValue
    }
  }
  public weak var uiDelegate: AptoPlatformUIDelegate? {
    get {
      return _uiDelegate
    }
    set {
      _uiDelegate = newValue
    }
  }

  /// Launch the full Apto UI SDK.
  /// - Parameter from: the view controller from which the Apto UI SDK will be launched.
  /// - Parameter mode: Specifies if the SDK will be open in embedded or standalone mode.
  /// - Parameter options: A set of flags that control whether some functions are available or not in the different screens.
  /// - Parameter initialUserData: User data that will be used in the sign up flow. If it's not provided, the SDK will ask for that data
  /// - Parameter initializationData: a `InitializationData` object that wraps additional user data. It can be nil.
  /// - Parameter googleMapsApiKey: The google maps api key that will be used to verify the user address.
  public func startCardFlow(from: UIViewController,
                            mode: AptoUISDKMode,
                            options: CardOptions? = nil,
                            initialUserData: DataPointList? = nil,
                            initializationData: InitializationData? = nil,
                            googleMapsApiKey: String? = nil,
                            completion: @escaping (Result<UIModule, NSError>.Callback)) {
    let launchOptions = CardModuleLaunchOptions(mode: mode,
                                                initialUserData: initialUserData,
                                                initializationData: initializationData,
                                                googleMapsApiKey: googleMapsApiKey,
                                                cardOptions: options,
                                                initialFlow: .fullSDK)
    launchCardFlow(from: from,
                   launchOptions: launchOptions,
                   completion: completion)
  }

  /// Launch the full Apto UI SDK.
  /// - Parameter from: the view controller from which the Apto UI SDK will be launched.
  /// - Parameter mode: Specifies if the SDK will be open in embedded or standalone mode.
  /// - Parameter options: A set of flags that control whether some functions are available or not in the different screens.
  /// - Parameter initialUserData: User data that will be used in the sign up flow. If it's not provided, the SDK will ask for that data
  /// - Parameter additionalData: a `AdditionalData` object that wraps additional user data. It can be nil.
  /// - Parameter googleMapsApiKey: The google maps api key that will be used to verify the user address.
  @objc public func startCardFlow(from: UIViewController,
                                  mode: AptoUISDKMode,
                                  options: CardOptions?,
                                  initialUserData: DataPointList?,
                                  initializationData: InitializationData? = nil,
                                  googleMapsApiKey: String?,
                                  completion: @escaping (_ module: UIModule?, _ error: NSError?) -> Void) {
    startCardFlow(from: from, mode: mode, options: options, initialUserData: initialUserData,
                  initializationData: initializationData, googleMapsApiKey: googleMapsApiKey) { result in
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let module):
        completion(module, nil)
      }
    }
  }

  /// Launch the Card issuance flow.
  /// - Parameter from: the view controller from which the Apto UI SDK will be launched.
  /// - Parameter mode: Specifies if the SDK will be open in embedded or standalone mode.
  /// - Parameter options: A set of flags that control whether some functions are available or not in the different screens.
  /// - Parameter initialUserData: User data that will be used in the sign up flow. If it's not provided, the SDK will ask for that data
  /// - Parameter initializationData: a `InitializationData` object that wraps additional user data. It can be nil.
  /// - Parameter googleMapsApiKey: The google maps api key that will be used to verify the user address.
  public func startNewCardApplicationFlow(from: UIViewController,
                                          mode: AptoUISDKMode,
                                          options: CardOptions? = nil,
                                          initialUserData: DataPointList? = nil,
                                          initializationData: InitializationData? = nil,
                                          googleMapsApiKey: String? = nil,
                                          completion: @escaping (Result<UIModule, NSError>.Callback)) {
    let launchOptions = CardModuleLaunchOptions(mode: mode,
                                                initialUserData: initialUserData,
                                                initializationData: initializationData,
                                                googleMapsApiKey: googleMapsApiKey,
                                                cardOptions: options,
                                                initialFlow: .newCardApplication)
    launchCardFlow(from: from,
                   launchOptions: launchOptions,
                   completion: completion)
  }

  /// Launch the Card issuance flow.
  /// - Parameter from: the view controller from which the Apto UI SDK will be launched.
  /// - Parameter mode: Specifies if the SDK will be open in embedded or standalone mode.
  /// - Parameter options: A set of flags that control whether some functions are available or not in the different screens.
  /// - Parameter initialUserData: User data that will be used in the sign up flow. If it's not provided, the SDK will ask for that data
  /// - Parameter initializationData: a `InitializationData` object that wraps additional user data. It can be nil.
  /// - Parameter googleMapsApiKey: The google maps api key that will be used to verify the user address.
  @objc public func startNewCardApplicationFlow(from: UIViewController,
                                                mode: AptoUISDKMode,
                                                options: CardOptions?,
                                                initialUserData: DataPointList?,
                                                initializationData: InitializationData? = nil,
                                                googleMapsApiKey: String?,
                                                completion: @escaping (_ module: UIModule?, _ error: NSError?) -> Void) {
    startNewCardApplicationFlow(from: from, mode: mode, options: options, initialUserData: initialUserData,
                                initializationData: initializationData, googleMapsApiKey: googleMapsApiKey) { result in
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let module):
        completion(module, nil)
      }
    }
  }

  public func startManageCardFlow(from: UIViewController,
                                  cardId: String,
                                  mode: AptoUISDKMode,
                                  options: CardOptions? = nil,
                                  googleMapsApiKey: String? = nil,
                                  completion: @escaping (Result<UIModule, NSError>.Callback)) {
    let launchOptions = CardModuleLaunchOptions(mode: mode,
                                                initialUserData: nil,
                                                initializationData: nil,
                                                googleMapsApiKey: googleMapsApiKey,
                                                cardOptions: options,
                                                initialFlow: .manageCard(cardId: cardId))
    launchCardFlow(from: from,
                   launchOptions: launchOptions,
                   completion: completion)
  }

  // swiftlint:disable:next function_parameter_count
  @objc public func startManageCardFlow(from: UIViewController,
                                        cardId: String,
                                        mode: AptoUISDKMode,
                                        options: CardOptions?,
                                        googleMapsApiKey: String?,
                                        completion: @escaping (_ module: UIModule?, _ error: NSError?) -> Void) {
    startManageCardFlow(from: from, cardId: cardId, mode: mode, options: options,
                        googleMapsApiKey: googleMapsApiKey) { result in
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let module):
        completion(module, nil)
      }
    }
  }
  
  @available(*, deprecated, message: "Use the cardMetadata parameter when launching the SDK.")
  public func setCardIssueAdditional(fields: [String: AnyObject]) {
    serviceLocator.systemServicesLocator.cardAdditionalFields().set(fields)
  }

  public func configure(_ completion: @escaping (Result<Bool, NSError>.Callback)) {
    fetchContextConfiguration { result in
      switch result {
      case .success:
        completion(.success(true))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Notifications

  private func setUpUINotificationObservers() {
    let notificationHandler = ServiceLocator.shared.notificationHandler
    notificationHandler.addObserver(self, selector: #selector(self.didRestoreNetworkConnectionUI),
                                    name: .NetworkReachableNotification)
    notificationHandler.addObserver(self, selector: #selector(self.didLoseNetworkConnectionUI),
                                    name: .NetworkNotReachableNotification)
    notificationHandler.addObserver(self, selector: #selector(self.didLoseConnectionToServerUI),
                                    name: .ServerMaintenanceNotification)
  }

  // MARK: Network connection error

  @objc private func didRestoreNetworkConnectionUI() {
    if uiDelegate?.shouldShowNoNetworkUI?() == false || !isPresentingNetworkNotReachable { return }
    dismissNetworkNotReachableError()
  }

  private func dismissNetworkNotReachableError() {
    lockingQueue.sync {
      isPresentingNetworkNotReachable = false
      UIApplication.topViewController()?.hideNetworkNotReachableError()
    }
  }

  @objc private func didLoseNetworkConnectionUI() {
    if uiDelegate?.shouldShowNoNetworkUI?() == false { return }
    presentNetworkNotReachableError()
  }

  // TODO: Extract to a component that handle the errors
  private func presentNetworkNotReachableError() {
    // Avoid showing the error twice
    lockingQueue.sync {
      guard isPresentingNetworkNotReachable == false else { return }
      isPresentingNetworkNotReachable = true
      let serviceLocator = ServiceLocator.shared
      if serviceLocator.uiConfig == nil {
        serviceLocator.uiConfig = fetchUIConfig()
      }
      UIApplication.topViewController()?.showNetworkNotReachableError(serviceLocator.uiConfig)
    }
  }

  @objc private func didLoseConnectionToServerUI() {
    if uiDelegate?.shouldShowServerMaintenanceUI?() == false { return }
    presentServerMaintenanceError()
  }

  private func presentServerMaintenanceError() {
    UIApplication.topViewController()?.showServerMaintenanceError()
  }

  // MARK: - Launch Card Flow

  private func launchCardFlow(from: UIViewController,
                              launchOptions: CardModuleLaunchOptions,
                              completion: @escaping (Result<UIModule, NSError>.Callback)) {
    _googleMapsApiKey = launchOptions.googleMapsApiKey
    setUpUINotificationObservers()
    setCardOptions(launchOptions.cardOptions)
    registerCustomFonts()
    fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let initializationData = InitializationData(userMetadata: launchOptions.initializationData?.userMetadata,
                                            cardMetadata: launchOptions.initializationData?.cardMetadata,
                                            custodianId: launchOptions.initializationData?.custodianId)
        let cardModule = CardModule(launchOptions: launchOptions, initializationData: initializationData)
        self.initialModule = cardModule
        cardModule.onClose = { [weak self, unowned from] module in
          from.dismiss(animated: true) {}
          self?.initialModule = nil
        }
        let uiConfig = UIConfig(projectConfiguration: contextConfiguration.projectConfiguration,
                                fontCustomizationOptions: launchOptions.cardOptions?.fontCustomizationOptions)
        cardModule.serviceLocator.uiConfig = uiConfig
        from.present(module: cardModule, animated: true, leftButtonMode: .close, uiConfig: uiConfig) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success:
            completion(.success(cardModule))
          }
        }
      }
    }
  }

  // MARK: - Initialize fonts

  private func registerCustomFonts(for bundle: Bundle = PodBundle.bundle()) {
    queue.sync {
      guard !fontRegistered else { return }
      fontRegistered = true
      guard let url = bundle.url(forResource: "ocraextended", withExtension: "ttf"),
            let fontDataProvider = CGDataProvider(url: url as CFURL),
            let font = CGFont(fontDataProvider) else {
        fatalError("Could not register fonts")
      }
      var error: Unmanaged<CFError>?
      guard CTFontManagerRegisterGraphicsFont(font, &error) else {
        fatalError("Could not register fonts")
      }
    }
  }
}
