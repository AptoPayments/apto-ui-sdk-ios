//
//  UIModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/03/2018.
//

import Foundation
import AptoSDK

open class UIModule: NSObject, UIModuleProtocol {

  // MARK: - Private Attributes

  // View Controllers and modules shown in the current module
  fileprivate var viewControllers: [UIViewController] = []
  fileprivate var uiModules: [UIModule] = []
  fileprivate var isDismissingWebModule: Bool = false

  // Parent module (if any)
  fileprivate weak var parentUIModule: UIModule?

  // View Controller and Module presented modally from the current module
  fileprivate var presentedViewController: UIViewController?
  fileprivate var presentedModule: UIModuleProtocol?

  // Current module navigation controller
  fileprivate var _navigationViewController: UINavigationController?
  var navigationController: UINavigationController? {
    get {
      if let navController = self._navigationViewController {
        return navController
      }
      return parentUIModule?.navigationController
    }
    set (navController) {
      self._navigationViewController = navController
    }
  }

  // UI Configuration
  public var uiConfig: UIConfig {
    return serviceLocator.uiConfig
  }

  // Service locator
  let serviceLocator: ServiceLocatorProtocol

  // Platform
  public var platform: AptoPlatformProtocol {
    return serviceLocator.platform
  }

  // Callbacks
  open var onClose: ((_ module: UIModuleProtocol) -> Void)?
  open var onNext: ((_ module: UIModuleProtocol) -> Void)?
  open var onFinish: ((_ result: UIModuleResult) -> Void)?

  // init
  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator

    super.init()
  }

  // MARK: - Module Lifecycle

  public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    // Implement in subclasses
    viewControllers = [UIViewController()]
    completion(.success(viewControllers[0]))
  }

  public func close() {
    onClose?(self)
  }

  public func finish(result: Any? = nil) {
    onFinish?(UIModuleResult(module: self, result: result))
  }

  public func next() {
    onNext?(self)
  }

  // MARK: - Methods to add or remove content in the current module

  public func push(viewController: UIViewController,
                   animated: Bool = true,
                   leftButtonMode: UIViewControllerLeftButtonMode = .back,
                   completion: @escaping (() -> Void)) {
    viewController.configureLeftNavButton(mode: leftButtonMode, uiConfig: uiConfig)
    navigationController?.pushViewController(viewController, animated: animated) { [ weak self] in
      self?.viewControllers.append(viewController)
      completion()
    }
  }

  public func popViewController(animated: Bool = true, completion: @escaping (() -> Void)) {
    navigationController?.popViewController(animated) { [ weak self] in
      self?.viewControllers.removeLast()
      completion()
    }
  }

  public func present(viewController: UIViewController, animated: Bool = true,
                      embedInNavigationController: Bool = false,
                      showNavigationBar: Bool = true,
                      presentationStyle: UIModalPresentationStyle? = nil,
                      completion: @escaping (() -> Void)) {
    var controller = viewController
    if embedInNavigationController {
      let newNavigationController = UINavigationController(rootViewController: controller)
        if showNavigationBar {
            newNavigationController.navigationBar.setUpWith(uiConfig: uiConfig)
            controller.configureLeftNavButton(mode: .close, uiConfig: uiConfig)
        }
      controller = newNavigationController
    }
    if let presentationStyle = presentationStyle {
        controller.modalPresentationStyle = presentationStyle
    } else {
        if #available(iOS 13.0, *), viewController.modalPresentationStyle != .overCurrentContext {
          controller.isModalInPresentation = true
          controller.modalPresentationStyle = .fullScreen
        }
    }
    
    navigationController?.viewControllers.last?.present(controller, animated: animated) { [weak self] in
      self?.presentedViewController = controller
      completion()
    }
  }

  public func push(module: UIModuleProtocol,
                   animated: Bool = true,
                   replacePrevious: Bool = false,
                   leftButtonMode: UIViewControllerLeftButtonMode = .back,
                   completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.initialize { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        module.parentUIModule = self
        self?.uiModules.append(module)
        self?.push(viewController: initialViewController, animated: animated, leftButtonMode: leftButtonMode) {
          if replacePrevious {
            guard let self = self else { return }
            if var controllers = self.navigationController?.viewControllers, controllers.count >= 2 {
              controllers.remove(at: controllers.count - 2)
              self.navigationController?.viewControllers = controllers
            }
          }
          completion(.success(initialViewController))
        }
      }
    }
  }

  public func popModule(animated: Bool = true, completion: @escaping (() -> Void)) {
    if uiModules.count <= 1 && viewControllers.isEmpty {
      // Last child module to pop. Close the current module instead
      self.close()
      completion()
    }
    else {
      if let module = uiModules.last {
        module.removeFromNavigationController(animated: animated) { [weak self] in
          self?.uiModules.removeLast()
          completion()
        }
      }
      else {
        completion()
      }
    }
  }

  public func remove(module: UIModuleProtocol, completion: @escaping (() -> Void)) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.removeFromNavigationController(animated: false) { [weak self] in
      guard let wself = self else {
        return
      }
      wself.uiModules = wself.uiModules.filter { $0 !== module }
      completion()
    }
  }

  public func present(module: UIModuleProtocol,
                      animated: Bool = true,
                      leftButtonMode: UIViewControllerLeftButtonMode = .close,
                      embedInNavigationController: Bool = true,
                      presenterController: UIViewController? = nil,
                      completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.initialize { [weak self] result in
      guard let wself = self, let uiConfig = self?.uiConfig else {
        return
      }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        let viewController: UIViewController
        if embedInNavigationController {
          let newNavigationController = UINavigationController(rootViewController: initialViewController)
          newNavigationController.navigationBar.setUpWith(uiConfig: uiConfig)
          module.navigationController = newNavigationController
          initialViewController.configureLeftNavButton(mode: leftButtonMode, uiConfig: uiConfig)
          viewController = newNavigationController
        }
        else {
          viewController = initialViewController
        }
        var presenterViewController: UIViewController?
        if presenterController != nil {
            presenterViewController = presenterController
        } else {
            presenterViewController = wself.navigationController?.viewControllers.last ?? UIApplication.topViewController()
        }
        if #available(iOS 13.0, *), viewController.modalPresentationStyle != .overCurrentContext {
          viewController.isModalInPresentation = true
          viewController.modalPresentationStyle = .fullScreen
        }
        presenterViewController?.present(viewController, animated: animated) { [weak self] in
          self?.presentedModule = module
          completion(.success(initialViewController))
        }
      }
    }
  }

  public func dismissViewController(animated: Bool = true, completion: @escaping (() -> Void)) {
    navigationController?.viewControllers.last?.dismiss(animated: animated, completion: completion)
  }

  public func dismissModule(animated: Bool = true, completion: @escaping (() -> Void)) {
    let dismissController = navigationController?.viewControllers.last ?? UIApplication.topViewController()
    dismissController?.dismiss(animated: animated, completion: completion)
  }

  public func addChild(module: UIModuleProtocol,
                       leftButtonMode: UIViewControllerLeftButtonMode = .back,
                       completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let module = module as? UIModule else {
      fatalError("module must inherit from UIModule")
    }
    module.initialize { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        module.parentUIModule = self
        self?.uiModules.append(module)
        if let uiConfig = self?.uiConfig {
          initialViewController.configureLeftNavButton(mode: leftButtonMode, uiConfig: uiConfig)
        }
        completion(.success(initialViewController))
      }
    }
  }

  public func addChild(viewController: UIViewController,
                       leftButtonMode: UIViewControllerLeftButtonMode = .back,
                       completion: @escaping Result<UIViewController, NSError>.Callback) {
    viewControllers.append(viewController)
    completion(.success(viewController))
  }

  // MARK: - Useful (helper) functions

  public func showLoadingSpinner(position: SubviewPosition = .center) {
    UIApplication.topViewController()?.showLoadingSpinner(tintColor: uiConfig.uiPrimaryColor,
                                                          position: position)
  }

  public func hideLoadingSpinner() {
    UIApplication.topViewController()?.hideLoadingSpinner()
  }

  public func showLoadingView() {
    UIApplication.topViewController()?.showLoadingView(uiConfig: serviceLocator.uiConfig)
  }

  public func hideLoadingView() {
    UIApplication.topViewController()?.hideLoadingView()
  }

  public func show(error: Error) {
    UIApplication.topViewController()?.show(error: error, uiConfig: uiConfig)
  }

  public func show(message: String, title: String, isError: Bool) {
    UIApplication.topViewController()?.show(message: message,
                                            title: title,
                                            isError: isError,
                                            uiConfig: uiConfig,
                                            tapHandler: nil)
  }

  // MARK: - Web Browser module
  func showExternal(url: URL, headers: [String: String]? = nil, useSafari: Bool? = false,
                    alternativeTitle: String? = nil, completion: (() -> Void)?) {
    if useSafari == true {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    else {
      let webBrowserModule = serviceLocator.moduleLocator.webBrowserModule(url: url, headers: headers,
                                                                           alternativeTitle: alternativeTitle)
      webBrowserModule.onClose = { [weak self] module in
        guard self?.isDismissingWebModule == false else { return }
        self?.isDismissingWebModule = true
        self?.dismissModule {
          completion?()
        }
      }
      self.present(module: webBrowserModule) { [weak self] _ in
        self?.isDismissingWebModule = false
      }
    }
  }

  func showExternal(url: URL, headers: [String: String]? = nil, useSafari: Bool? = false,
                    alternativeTitle: String? = nil) {
    showExternal(url: url, headers: headers, useSafari: useSafari, alternativeTitle: alternativeTitle, completion: nil)
  }

  // MARK: - Private Methods to remove the current module from navigation controller

  fileprivate func removeFromNavigationController(animated: Bool, completion: @escaping (() -> Void)) {
    removeChildModules(animated: animated) { [weak self] in
      if !animated {
        self?.removeViewControllers()
        self?.navigationController?.popViewController(animated, completion: completion)
      }
      else {
        guard let viewControllers = self?.viewControllers, !viewControllers.isEmpty else {
          self?.navigationController?.popViewController(animated, completion: completion)
          return
        }
        self?.removeViewControllersTail()
        guard let navigationController = self?.navigationController else {
          completion()
          return
        }
        navigationController.popViewController(animated, completion: completion)
      }
    }
  }

  fileprivate func removeViewControllers() {
    guard let navigationController = self.navigationController else {
      return
    }
    let filteredViewControllers = navigationController.viewControllers.filter { !self.viewControllers.contains($0) }
    navigationController.setViewControllers(filteredViewControllers, animated: false)
    self.viewControllers = []
  }

  fileprivate func removeViewControllersTail() {
    guard let navigationController = self.navigationController, self.viewControllers.count > 1 else {
      return
    }
    var viewControllersTail = self.viewControllers
    let initialViewController = viewControllersTail.remove(at: 0)
    let filteredViewControllers = navigationController.viewControllers.filter { !viewControllersTail.contains($0) }
    navigationController.setViewControllers(filteredViewControllers, animated: false)
    self.viewControllers = [initialViewController]
  }

  fileprivate func removeChildModules(animated: Bool, completion: @escaping (() -> Void)) {
    let myGroup = DispatchGroup()
    for childModule in uiModules {
      myGroup.enter()
      childModule.removeFromNavigationController(animated: animated) {
        myGroup.leave()
      }
    }
    myGroup.notify(queue: .main) {
      completion()
    }
  }

  fileprivate var navigationBarBackgroundImage: UIImage?
  fileprivate var navigationBarShadowImage: UIImage?
  fileprivate var navigationBarIsTranslucent: Bool = false
  fileprivate var navigationBarViewBackgroundColor: UIColor?
  fileprivate var navigationBarBackgroundColor: UIColor?
  fileprivate var navigationBarTransparentStyleApplied = false

  func makeNavigationBarTransparent() {
    if let navigationController = self.navigationController {
      self.navigationBarBackgroundImage = navigationController.navigationBar.backgroundImage(for: UIBarMetrics.default)
      self.navigationBarShadowImage = navigationController.navigationBar.shadowImage
      self.navigationBarIsTranslucent = navigationController.navigationBar.isTranslucent
      self.navigationBarViewBackgroundColor = navigationController.view.backgroundColor
      self.navigationBarBackgroundColor = navigationController.navigationBar.backgroundColor
      self.navigationBarTransparentStyleApplied = true
      navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
      navigationController.navigationBar.shadowImage = UIImage()
      navigationController.navigationBar.isTranslucent = true
      navigationController.view.backgroundColor = .clear
      navigationController.navigationBar.backgroundColor = .clear
    }
  }

  func restoreNavigationBarFromTransparentState() {
    if let navigationController = self.navigationController, self.navigationBarTransparentStyleApplied == true {
      navigationController.navigationBar.setBackgroundImage(navigationBarBackgroundImage, for: UIBarMetrics.default)
      navigationController.navigationBar.shadowImage = self.navigationBarShadowImage
      navigationController.navigationBar.isTranslucent = self.navigationBarIsTranslucent
      navigationController.view.backgroundColor = self.navigationBarViewBackgroundColor
      navigationController.navigationBar.backgroundColor = self.navigationBarBackgroundColor
    }
  }
}

// MARK: - Smooth push / pop transitions

extension UIViewController {
  public func present(module: UIModule,
                      animated: Bool = true,
                      leftButtonMode: UIViewControllerLeftButtonMode = .back,
                      uiConfig: UIConfig,
                      completion: @escaping Result<UIViewController, NSError>.Callback) {
    module.initialize { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let initialViewController):
        let newNavigationController = UINavigationController(rootViewController: initialViewController)
        newNavigationController.navigationBar.setUpWith(uiConfig: uiConfig)
        module.navigationController = newNavigationController
        initialViewController.configureLeftNavButton(mode: leftButtonMode, uiConfig: uiConfig)
        if #available(iOS 13.0, *), newNavigationController.modalPresentationStyle != .overCurrentContext {
          newNavigationController.isModalInPresentation = true
          newNavigationController.modalPresentationStyle = .fullScreen
        }
        self?.present(newNavigationController, animated: animated) {
          completion(.success(initialViewController))
        }
      }
    }
  }

  public func configureLeftNavButton(mode: UIViewControllerLeftButtonMode?, uiConfig: UIConfig?) {
    guard !navigationItem.hidesBackButton else {
      hideNavPreviousButton()
      hideNavCancelButton()
      return
    }
    if let mode = mode, let uiConfig = uiConfig {
      switch mode {
      case .back:
        showNavPreviousButton(uiConfig.textTopBarPrimaryColor)
      case .close:
        showNavCancelButton(uiConfig.textTopBarPrimaryColor)
      case .none:
        hideNavPreviousButton()
      }
    }
  }
}
