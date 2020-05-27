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
 
  public func startCardFlow(from: UIViewController, mode: ShiftCardModuleMode, initialUserData: DataPointList? = nil,
                            options: CardOptions? = nil, googleMapsApiKey: String? = nil,
                            completion: @escaping (Result<UIModule, NSError>.Callback)) {
    _googleMapsApiKey = googleMapsApiKey
    setUpUINotificationObservers()
    setCardOptions(options)
    registerCustomFonts()
    fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let shiftCardModule = ShiftCardModule(mode: mode, initialUserData: initialUserData, options: options)
        self.initialModule = shiftCardModule
        shiftCardModule.onClose = { [weak self, unowned from] module in
          from.dismiss(animated: true) {}
          self?.initialModule = nil
        }
        let uiConfig = UIConfig(projectConfiguration: contextConfiguration.projectConfiguration,
                                fontCustomizationOptions: options?.fontCustomizationOptions)
        shiftCardModule.serviceLocator.uiConfig = uiConfig
        from.present(module: shiftCardModule, animated: true, leftButtonMode: .close, uiConfig: uiConfig) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success:
            completion(.success(shiftCardModule))
          }
        }
      }
    }
  }

  // swiftlint:disable:next function_parameter_count
  @objc public func startCardFlow(from: UIViewController, mode: ShiftCardModuleMode,
                                  initialUserData: DataPointList?, options: CardOptions?, googleMapsApiKey: String?,
                                  completion: @escaping (_ module: UIModule?, _ error: NSError?) -> Void) {
    startCardFlow(from: from, mode: mode, initialUserData: initialUserData, options: options,
                  googleMapsApiKey: googleMapsApiKey) { result in
      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let module):
        completion(module, nil)
      }
    }
  }
  
  /// Set extra metadata parameters when issuing a card
  /// - Parameter fields: extra metadata fields
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

  // MARK: - Initialize fonts

  func registerCustomFonts(for bundle: Bundle = PodBundle.bundle()) {
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
