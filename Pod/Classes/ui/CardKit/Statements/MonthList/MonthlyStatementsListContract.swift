//
//  MonthlyStatementsListModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

import AptoSDK
import Bond

protocol MonthlyStatementsListModuleProtocol: UIModuleProtocol {
    func showStatementReport(month: Month)
}

protocol MonthlyStatementsListInteractorProtocol {
    func fetchStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback)
}

class MonthlyStatementsListViewModel {
    let months: MutableObservableArray2D<String, Month> = MutableObservableArray2D(Array2D())
    let dataLoaded: Observable<Bool> = Observable(false)
    let error: Observable<NSError?> = Observable(nil)
}

protocol MonthlyStatementsListPresenterProtocol: AnyObject {
    var router: MonthlyStatementsListModuleProtocol? { get set }
    var interactor: MonthlyStatementsListInteractorProtocol? { get set }
    var viewModel: MonthlyStatementsListViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }

    func viewLoaded()
    func closeTapped()
    func monthSelected(_ month: Month)
}

class FetchStatementReportError: NSError {
    private let errorDomain = "com.aptopayments.statements.download.error"
    private let errorCode = 4443

    init() {
        let userInfo = [NSLocalizedDescriptionKey: "monthly_statements.list.error_generating_report.message".podLocalized()]
        super.init(domain: errorDomain, code: errorCode, userInfo: userInfo)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
