//
// DataConfirmationViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/11/2018.
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class DataConfirmationViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private let presenter: DataConfirmationPresenterProtocol
  private let formView = MultiStepForm()
  private let formatterFactory = DataPointFormatterFactory()

  init(uiConfiguration: UIConfig, presenter: DataConfirmationPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not being implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  override func nextTapped() {
    presenter.confirmDataTapped()
  }

  private func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.userData.observeNext { [unowned self] userData in
      self.setUpUI(for: userData)
    }.dispose(in: disposeBag)
    viewModel.error.ignoreNils().observeNext { [unowned self] error in
      self.show(error: error)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension DataConfirmationViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.uiSecondaryColor)
    navigationController?.navigationBar.isTranslucent = true
    showNavPreviousButton(uiTheme: .theme2)
    setUpRefreshButton()
  }

  func setUpRefreshButton() {
    let title = "select_balance_store.oauth_confirm.refresh.title".podLocalized()
    let icon = UIImage.imageFromPodBundle("btn_refresh_sources")?.asTemplate()
    let barButtonItem = TopBarButtonItem(uiConfig: uiConfiguration,
                                         text: title,
                                         icon: icon) { [unowned self] in
      self.presenter.reloadTapped()
    }
    let color = uiConfiguration.uiPrimaryColor
    barButtonItem.labelBackgroundColor = color
    barButtonItem.tintColor = color
    barButtonItem.labelTextColor = uiConfiguration.textButtonColor
    navigationItem.rightBarButtonItem = barButtonItem
  }

  func setUpUI(for userData: DataPointList?) {
    guard let userData = userData else {
      return
    }

    var rows = createTitleAndExplanation()
    rows.append(contentsOf: createRows(for: userData))
    rows.append(contentsOf: createActionRows())
    formView.show(rows: rows)
  }

  func createTitleAndExplanation() -> [FormRowView] {
    let title = ComponentCatalog.largeTitleLabelWith(text: "select_balance_store.oauth_confirm.title".podLocalized(),
                                                     uiConfig: uiConfiguration)
    let localizedExplanation = "select_balance_store.oauth_confirm.explanation".podLocalized()
    let explanation = ComponentCatalog.formLabelWith(text: localizedExplanation,
                                                     multiline: true,
                                                     lineSpacing: uiConfiguration.lineSpacing,
                                                     letterSpacing: uiConfiguration.letterSpacing,
                                                     uiConfig: uiConfiguration)
    return [
      FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 16),
      customRowWithView(title),
      FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 8),
      customRowWithView(explanation),
      FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 16)]
  }

  func customRowWithView(_ view: UIView) -> FormRowCustomView {
    let retVal = FormRowCustomView(view: view, showSplitter: false)
    retVal.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    retVal.padding = uiConfiguration.formRowPadding
    return retVal
  }

  func createRows(for userData: DataPointList) -> [FormRowView] {
    var rows = [FormRowView]()
    userData.forEach {
      let formatter = formatterFactory.formatter(for: $0)
      formatter.titleValues.forEach {
        rows.append(FormBuilder.sectionTitleRowWith(text: $0.title, height: 26, uiConfig: uiConfiguration))
        rows.append(FormBuilder.formAnswerRowWith(text: $0.value, height: 24, uiConfig: uiConfiguration))
        rows.append(FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 20))
      }
    }
    return rows
  }

  func createActionRows() -> [FormRowView] {
    let content = "select_balance_store.oauth_confirm.footer".podLocalized()
    let confirmTitle = "select_balance_store.oauth_confirm.call_to_action.title".podLocalized()
    let confirmButton = ComponentCatalog.buttonWith(title: confirmTitle,
                                                    showShadow: false,
                                                    uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.confirmDataTapped()
    }
    return [
      FormBuilder.richTextNoteRowWith(text: styledContent(content),
                                      multiline: true,
                                      uiConfig: uiConfiguration,
                                      linkHandler: LinkHandler(urlHandler: self)),
      FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 22),
      customRowWithView(confirmButton),
      FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 20)
    ]
  }

  func styledContent(_ content: String) -> NSAttributedString {
    let htmlData = content.data(using: String.Encoding.utf8)
    guard let data = htmlData else {
      return NSAttributedString(string: content)
    }
    let options = [
      NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as Any
    ]
    do {
      let attrString = try NSAttributedString(data: data,
                                              options: options,
                                              documentAttributes: nil).mutableCopy() as? NSMutableAttributedString
      guard let mutableAttrString = attrString else {
        return NSAttributedString(string: content)
      }
      mutableAttrString.replacePlainTextStyle(font: uiConfiguration.fontProvider.instructionsFont,
                                              color: uiConfiguration.textTertiaryColor,
                                              paragraphSpacing: 4)
      mutableAttrString.replaceLinkStyle(font: uiConfiguration.fontProvider.formTextLink,
                                         color: uiConfiguration.textSecondaryColor,
                                         paragraphSpacing: 0)
      return mutableAttrString
    }
    catch {
      return NSAttributedString(string: content)
    }
  }
}

extension DataConfirmationViewControllerTheme2: URLHandlerProtocol {
  public func showExternal(url: URL, headers: [String: String]?, useSafari: Bool?, alternativeTitle: String?) {
    presenter.show(url: url)
  }
}
