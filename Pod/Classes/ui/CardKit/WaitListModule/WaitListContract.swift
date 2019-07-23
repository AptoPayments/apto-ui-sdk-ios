//
//  WaitListContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK
import Bond

class WaitListViewModel {
  let asset: Observable<String?> = Observable(nil)
  let backgroundImage: Observable<String?> = Observable(nil)
  let backgroundColor: Observable<String?> = Observable(nil)
}

// Card application wait list

protocol WaitListModuleProtocol: UIModuleProtocol {
  func applicationStatusChanged()
}

protocol WaitListInteractorProtocol {
  func reloadApplication(completion: @escaping Result<CardApplication, NSError>.Callback)
}

protocol WaitListPresenterProtocol: class {
  var viewModel: WaitListViewModel { get }

  func viewLoaded()
}

protocol CardApplicationWaitListPresenterProtocol: WaitListPresenterProtocol {
  var interactor: WaitListInteractorProtocol? { get set }
  var router: WaitListModuleProtocol? { get set }
  var analyticsManager: AnalyticsServiceProtocol? { get set }
}

// Card wait list

protocol CardWaitListModuleProtocol: UIModuleProtocol {
  func cardStatusChanged()
}

protocol CardWaitListInteractorProtocol {
  func reloadCard(completion: @escaping Result<Card, NSError>.Callback)
}

protocol CardWaitListPresenterProtocol: WaitListPresenterProtocol {
  var interactor: CardWaitListInteractorProtocol? { get set }
  var router: CardWaitListModuleProtocol? { get set }
  var analyticsManager: AnalyticsServiceProtocol? { get set }
}
