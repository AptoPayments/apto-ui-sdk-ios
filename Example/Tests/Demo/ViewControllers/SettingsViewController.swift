//
//  SettingsViewController.swift
//  Ledge Demo
//
//  Created by Ivan Oliver on 01/25/2016.
//  Copyright (c) 2016 Ivan Oliver. All rights reserved.
//

import LedgeLink
import UIKit

class SettingsViewController: UIViewController {
    private enum Params {
        static let labelWidth: CGFloat = 120
        static let blueColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
    }

    private let formView = MultiStepForm()
    private var rows: [FormRowView]?
    private let flatView = UIImageView(image: UIImage(named: "BackgroundImage"))
    private var manager: LedgeLink!
    private var applicationData: LoanApplication!
    private var flowConfiguration: LedgeLinkFlowConfig!

    convenience init(manager: LedgeLink, applicationData: LoanApplication, flowConfiguration: LedgeLinkFlowConfig) {
        self.init()
        self.manager = manager
        self.applicationData = applicationData
        self.flowConfiguration = flowConfiguration
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(formView)
        formView.snp_makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
        formView.backgroundColor = UIColor.clearColor()

        title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(SettingsViewController.cancelClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(SettingsViewController.saveClicked))

        // UI Setup
        setupFormFields { [weak self] in
            guard let rows = self?.rows else {
                return
            }
            self?.flatView.backgroundColor = UIColor.redColor()
            var buildType = "Dev"
            if ALPHA_BUILD {
                buildType = "Alpha"
            } else if BETA_BUILD {
                buildType = "Beta"
            } else if RELEASE_BUILD {
                buildType = ""
            }
            self?.formView.show(rows: rows)
            self?.fillInDataFromInitialParameters()
            self?.newUserTokenReceived(self?.manager.userToken)
        }
    }

    @objc private func cancelClicked() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private var amountField: FormRowTextInputView?
    private var loanPurposeField: FormRowValuePickerView?
    private var housingTypeField: FormRowValuePickerView?
    private var employmentStatusField: FormRowValuePickerView?
    private var salaryFrequencyField: FormRowValuePickerView?
    private var firstNameField: FormRowTextInputView?
    private var lastNameField: FormRowTextInputView?
    private var emailField: FormRowTextInputView?
    private var phoneField: FormRowTextInputView?
    private var addressField: FormRowTextInputView?
    private var aptUnitField: FormRowTextInputView?
    private var cityField: FormRowTextInputView?
    private var stateField: FormRowTextInputView?
    private var zipField: FormRowTextInputView?
    private var incomeField: FormRowTextInputView?
    private var monthlyNetIncomeField: FormRowTextInputView?
    private var creditScoreField: FormRowTextInputView?
    private var birthdayField: FormRowDatePickerView?
    private var tokenRow: FormRowTitleSubtitleView?
    private var skipStepsRow: FormRowSwitchView?
    private var strictAddressRow: FormRowSwitchView?

    private func setupFormFields(completion: () -> Void) {
        let explanationRow = FormRowLabelView(label: explanationLabel("launcher.title.initial-values".localized()), showSplitter: false)
        amountField = FormRowTextInputView(label: label("launcher.amount".localized()), labelWidth: Params.labelWidth, textField: UITextField(), firstFormField: true)
        firstNameField = FormRowTextInputView(label: label("launcher.first-name".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        lastNameField = FormRowTextInputView(label: label("launcher.last-name".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        emailField = FormRowTextInputView(label: label("launcher.email".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        phoneField = FormRowTextInputView(label: label("launcher.phone".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        addressField = FormRowTextInputView(label: label("launcher.address".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        aptUnitField = FormRowTextInputView(label: label("launcher.apt-unit".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        cityField = FormRowTextInputView(label: label("launcher.city".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        stateField = FormRowTextInputView(label: label("launcher.state".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        zipField = FormRowTextInputView(label: label("launcher.zip-code".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        incomeField = FormRowTextInputView(label: label("launcher.income".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        monthlyNetIncomeField = FormRowTextInputView(label: label("launcher.monthly-income".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        creditScoreField = FormRowTextInputView(label: label("launcher.credit-score".localized()), labelWidth: Params.labelWidth, textField: UITextField())
        birthdayField = FormRowDatePickerView(label: label("launcher.birthday".localized()), labelWidth: Params.labelWidth, textField: UITextField(), date: NSDate(), format: .DateOnly)
        tokenRow = FormRowTitleSubtitleView(
            titleLabel: smallBoldLabel("launcher.user-token".localized()),
            subtitleLabel: smallLabel(" "),
            rightIcon: UIImage(named: "CloseIcon.png"),
            showSplitter: true
        ) {
            self.manager.clearUserToken()
        }

        skipStepsRow = FormRowSwitchView(label: label("launcher.switch.skip-steps".localized()), labelWidth: Params.labelWidth, switcher: switcher())
        strictAddressRow = FormRowSwitchView(label: label("launcher.switch.address-check".localized()), labelWidth: Params.labelWidth, switcher: switcher())

        let doubleButtonRow = FormRowDoubleButtonView(leftButton: smallButton("launcher.button.clear-data".localized()), rightButton: smallButton("launcher.button.example-data".localized()), leftTapHandler: {
            self.clearData()
        }, rightTapHandler: {
            self.fillInData()
        })

        manager.loadConfigFromServer { result in
            switch result {
            case let .Failure(error):
                self.showError(error)
            case .Success:

                var purposeValues = [FormValuePickerValue]()
                for loanPurpose in self.manager.availableLoanPurposes! { purposeValues.append(FormValuePickerValue(id: String(loanPurpose.loanPurposeId), text: loanPurpose.description)) }
                self.loanPurposeField = self.valuePickerRowWith(label: "launcher.purpose".localized(), placeholder: "launcher.purpose.placeholder".localized(), value: "", values: purposeValues)

                var housingTypeValues = [FormValuePickerValue]()
                for housingType in self.manager.availableHousingTypes! { housingTypeValues.append(FormValuePickerValue(id: String(housingType.housingTypeId), text: housingType.description)) }
                self.housingTypeField = self.valuePickerRowWith(label: "launcher.residence".localized(), placeholder: "", value: "", values: housingTypeValues)

                var employmentStatusValues = [FormValuePickerValue]()
                for employmentStatus in self.manager.availableEmploymentStatuses! { employmentStatusValues.append(FormValuePickerValue(id: String(employmentStatus.employmentStatusId), text: employmentStatus.description)) }
                self.employmentStatusField = self.valuePickerRowWith(label: "launcher.employment-status".localized(), placeholder: "", value: "", values: employmentStatusValues)

                var salaryFrequencyValues = [FormValuePickerValue]()
                for salaryFrequency in self.manager.availableSalaryFrequencies! { salaryFrequencyValues.append(FormValuePickerValue(id: String(salaryFrequency.salaryFrequencyId), text: salaryFrequency.description)) }
                self.salaryFrequencyField = self.valuePickerRowWith(label: "launcher.salary-frequency".localized(), placeholder: "", value: "", values: salaryFrequencyValues)

                self.rows = [explanationRow, self.amountField!, self.loanPurposeField!, self.firstNameField!, self.lastNameField!, self.emailField!, self.phoneField!, self.addressField!, self.aptUnitField!, self.cityField!, self.stateField!, self.zipField!, self.housingTypeField!, self.incomeField!, self.monthlyNetIncomeField!, self.employmentStatusField!, self.salaryFrequencyField!, self.creditScoreField!, self.birthdayField!, self.tokenRow!, self.skipStepsRow!, self.strictAddressRow!, doubleButtonRow]

                completion()
            }
        }
    }

    func explanationLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        label.textColor = UIColor.darkGrayColor()
        label.textAlignment = .Center
        return label
    }

    func label(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }

    func smallBoldLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFontOfSize(12)
        return label
    }

    func smallLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFontOfSize(12)
        return label
    }

    func button(text: String) -> UIButton {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.backgroundColor = Params.blueColor
        button.setTitle(text, forState: .Normal)
        return button
    }

    func smallButton(text: String) -> UIButton {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.backgroundColor = UIColor.lightGrayColor()
        button.setTitle(text, forState: .Normal)
        return button
    }

    func switcher() -> UISwitch {
        let switcher = UISwitch()
        switcher.onTintColor = Params.blueColor
        return switcher
    }

    func valuePickerRowWith(label label: String, placeholder _: String, labelWidth _: CGFloat? = nil, value: String?, values: [FormValuePickerValue], validator: DataValidator<String>? = nil) -> FormRowValuePickerView {
        let uilabel = self.label(label)
        let retVal = FormRowValuePickerView(label: uilabel, labelWidth: Params.labelWidth, textField: UITextField(), value: value, values: values, validator: validator)
        return retVal
    }

    @objc func saveClicked() {
        applicationData.loanData.amount = Amount(value: safeDouble(amountField!.textField.text), currency: "USD")
        applicationData.loanData.purposeId = safeInt(loanPurposeField!.selectedValue)
        applicationData.borrowerData.name.firstName = safeText(firstNameField!.textField.text)
        applicationData.borrowerData.name.lastName = safeText(lastNameField!.textField.text)
        applicationData.borrowerData.email = safeText(emailField!.textField.text)
        applicationData.borrowerData.phoneNumber.regionCode = "US"
        applicationData.borrowerData.phoneNumber.phoneNumber = safeText(phoneField!.textField.text)
        applicationData.borrowerData.birthday = birthdayField?.date
        applicationData.borrowerData.address.address = safeText(addressField!.textField.text)
        applicationData.borrowerData.address.apUnit = safeText(aptUnitField!.textField.text)
        applicationData.borrowerData.address.city = safeText(cityField!.textField.text)
        applicationData.borrowerData.address.stateCode = safeText(stateField!.textField.text)
        applicationData.borrowerData.address.zip = safeText(zipField!.textField.text)
        let housingTypeId = safeInt(housingTypeField!.selectedValue)
        applicationData.borrowerData.housingType = housingTypeId != nil ? LedgeLink.defaultManager().availableHousingTypes?.filter { $0.housingTypeId == housingTypeId }.first : nil
        applicationData.borrowerData.income = safeDouble(incomeField!.textField.text)
        applicationData.borrowerData.monthlyNetIncome = safeDouble(monthlyNetIncomeField!.textField.text)
        let employmentStatusId = safeInt(employmentStatusField!.selectedValue)
        applicationData.borrowerData.employmentStatus = employmentStatusId != nil ? LedgeLink.defaultManager().availableEmploymentStatuses?.filter { $0.employmentStatusId == employmentStatusId }.first : nil
        let salaryFrequencyId = safeInt(salaryFrequencyField!.selectedValue)
        applicationData.borrowerData.salaryFrequency = salaryFrequencyId != nil ? LedgeLink.defaultManager().availableSalaryFrequencies?.filter { $0.salaryFrequencyId == salaryFrequencyId }.first : nil
        applicationData.borrowerData.creditScore = safeInt(creditScoreField!.textField.text)

        flowConfiguration.uiConfig.formLabelTextFocusedColor = colorize(0x006837)
        flowConfiguration.uiConfig.formAuxiliarViewBackgroundColor = colorize(0xFAFAFA)
        flowConfiguration.uiConfig.formSliderHighlightedTrackColor = colorize(0x006837)
        flowConfiguration.uiConfig.formSliderValueTextColor = colorize(0x006837)
        flowConfiguration.uiConfig.tintColor = colorize(0x17A94F)
        flowConfiguration.uiConfig.offerApplyButtonTextColor = colorize(0x17A94F)
        flowConfiguration.uiConfig.disabledTintColor = colorize(0xA9A9A9)
        flowConfiguration.uiConfig.offerListStyle = .Carousel

        // Behavior configuration
        flowConfiguration.skipSteps = skipStepsRow?.switcher.on ?? false
        flowConfiguration.strictAddressValidation = strictAddressRow?.switcher.on ?? false
        //    flowConfiguration.GoogleGeocodingAPIKey = "[YOUR_GOOGLE_GEOCODING_KEY]"

        flowConfiguration.GoogleGeocodingAPIKey = "AIzaSyChG61EnKGAlmhP5tdd4RtE5s8Hpi8EOII"
        flowConfiguration.maxAmount = 25000
        flowConfiguration.amountIncrements = 500

        // Launch default UI
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func fillInData() {
        amountField!.textField.text = "100"
        loanPurposeField!.selectedValue = "1"
        firstNameField!.textField.text = "John"
        lastNameField!.textField.text = "Smith"
        emailField!.textField.text = "john.smith@gmail.com"
        phoneField!.textField.text = "2015555555"
        addressField!.textField.text = "1310 Fillmore st"
        aptUnitField!.textField.text = "123"
        cityField!.textField.text = "San Francisco"
        stateField!.textField.text = "CA"
        zipField!.textField.text = "94115"
        housingTypeField!.selectedValue = "1"
        salaryFrequencyField!.selectedValue = "1"
        employmentStatusField!.selectedValue = "1"
        incomeField?.textField.text = "60000"
        monthlyNetIncomeField?.textField.text = "5000"
        creditScoreField?.textField.text = "2"
        guard let date = NSDate.dateFromJSONAPIFormat("2-8-1980") else {
            return
        }
        birthdayField?.date = date
    }

    private func fillInDataFromInitialParameters() {
        if let amount = applicationData.loanData.amount!.value {
            amountField!.textField.text = "\(amount)"
        } else {
            amountField!.textField.text = ""
        }
        loanPurposeField!.selectedValue = applicationData.loanData.purposeId != nil ? "\(applicationData.loanData.purposeId!)" : nil
        firstNameField!.textField.text = "\(applicationData.borrowerData.name.firstName ?? "")"
        lastNameField!.textField.text = "\(applicationData.borrowerData.name.lastName ?? "")"
        emailField!.textField.text = "\(applicationData.borrowerData.email ?? "")"
        phoneField!.textField.text = "\(applicationData.borrowerData.phoneNumber.phoneNumber ?? "")"
        addressField!.textField.text = "\(applicationData.borrowerData.address.address ?? "")"
        aptUnitField!.textField.text = "\(applicationData.borrowerData.address.apUnit ?? "")"
        cityField!.textField.text = "\(applicationData.borrowerData.address.city ?? "")"
        stateField!.textField.text = "\(applicationData.borrowerData.address.stateCode ?? "")"
        zipField!.textField.text = "\(applicationData.borrowerData.address.zip ?? "")"
        housingTypeField!.selectedValue = applicationData.borrowerData.housingType != nil ? "\(applicationData.borrowerData.housingType!.housingTypeId)" : nil
        salaryFrequencyField!.selectedValue = applicationData.borrowerData.salaryFrequency != nil ? "\(applicationData.borrowerData.salaryFrequency!.salaryFrequencyId)" : nil
        employmentStatusField!.selectedValue = applicationData.borrowerData.employmentStatus != nil ? "\(applicationData.borrowerData.employmentStatus!.employmentStatusId)" : nil
        if let income = applicationData.borrowerData.income {
            incomeField!.textField.text = "\(income)"
        } else {
            incomeField!.textField.text = ""
        }
        if let monthlyNetIncome = applicationData.borrowerData.monthlyNetIncome {
            monthlyNetIncomeField!.textField.text = "\(monthlyNetIncome)"
        } else {
            monthlyNetIncomeField!.textField.text = ""
        }
        creditScoreField?.textField.text = applicationData.borrowerData.creditScore != nil ? "\(applicationData.borrowerData.creditScore!)" : nil
        birthdayField?.date = applicationData.borrowerData.birthday != nil ? applicationData.borrowerData.birthday! : nil

        skipStepsRow?.switcher.on = flowConfiguration.skipSteps
        strictAddressRow?.switcher.on = flowConfiguration.strictAddressValidation
    }

    private func clearData() {
        amountField!.textField.text = ""
        loanPurposeField!.selectedValue = nil
        firstNameField!.textField.text = ""
        lastNameField!.textField.text = ""
        emailField!.textField.text = ""
        phoneField!.textField.text = ""
        addressField!.textField.text = ""
        aptUnitField!.textField.text = ""
        cityField!.textField.text = ""
        stateField!.textField.text = ""
        zipField!.textField.text = ""
        housingTypeField!.selectedValue = nil
        incomeField?.textField.text = ""
        monthlyNetIncomeField?.textField.text = ""
        employmentStatusField!.selectedValue = nil
        salaryFrequencyField!.selectedValue = nil
        creditScoreField?.textField.text = ""
        birthdayField?.date = nil
        formView.resignFirstResponder()
        skipStepsRow?.switcher.on = false
        strictAddressRow?.switcher.on = false
    }

    private func safeDouble(text: String?) -> Double? {
        guard let text = text else {
            return nil
        }
        return Double(text)
    }

    private func safeInt(text: String?) -> Int? {
        guard let text = text else {
            return nil
        }
        return Int(text)
    }

    private func safeText(text: String?) -> String? {
        guard let text = text else {
            return nil
        }
        return text.characters.count > 0 ? text : nil
    }

    private func colorize(hex: Int, alpha: Double = 1.0) -> UIColor {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}

extension SettingsViewController: LedgeLinkDelegate {
    func newUserTokenReceived(userToken: String?) {
        guard let tokenRow = tokenRow else {
            return
        }
        tokenRow.subtitleLabel.text = userToken
        tokenRow.showRightButton()
    }

    private func clearUserToken() {
        guard let tokenRow = tokenRow else {
            return
        }
        tokenRow.subtitleLabel.text = " "
        tokenRow.hideRightButton()
    }
}

extension SettingsViewController: LedgeLinkUIDelegate {
    func didFailShowingUserInterface(error: NSError) {
        hideBackgroundView()
        showError(error)
    }

    func didShowUserInterface() {
        showBackgroundView()
    }

    func didCloseUserInterface() {
        hideBackgroundView()
    }

    private func showBackgroundView() {
        view.addSubview(flatView)
        flatView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(self.view)
        }
        flatView.alpha = 0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.flatView.alpha = 1
        })
    }

    private func hideBackgroundView() {
        UIView.animateWithDuration(0.3, animations: {
            self.flatView.alpha = 0
        }) { _ in
            self.flatView.removeFromSuperview()
        }
    }

    private func showError(error: NSError) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
