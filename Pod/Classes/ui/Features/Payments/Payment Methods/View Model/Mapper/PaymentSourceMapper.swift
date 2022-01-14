import AptoSDK

struct PaymentSourceMapper {
    func map(elements: [PaymentSource], action: ((PaymentMethodItem) -> Void)? = nil,
             deleteAction: ((PaymentMethodItem) -> Void)? = nil) -> [PaymentMethodItem]
    {
        elements.map { self.map($0, action: action, deleteAction: deleteAction) }
    }

    func map(_ from: PaymentSource, action: ((PaymentMethodItem) -> Void)?,
             deleteAction: ((PaymentMethodItem) -> Void)?) -> PaymentMethodItem
    {
        switch from {
        case let .card(card):
            return mapCard(card, action: action, deleteAction: deleteAction)
        case let .bankAccount(bankAccount):
            return mapBankAccount(bankAccount)
        }
    }

    private func mapCard(_ card: CardPaymentSource, action: ((PaymentMethodItem) -> Void)?,
                         deleteAction: ((PaymentMethodItem) -> Void)?) -> PaymentMethodItem
    {
        PaymentMethodItem(id: card.id,
                          type: .card,
                          title: "•••• \(card.lastFour)",
                          subtitle: card.title,
                          isSelected: card.isPreferred,
                          icon: icon(from: card.network),
                          action: action, deleteAction: deleteAction)
    }

    private func mapBankAccount(_ bankAccount: BankAccountPaymentSource) -> PaymentMethodItem {
        PaymentMethodItem(id: bankAccount.id,
                          type: .bankAccount,
                          title: "", subtitle: "",
                          icon: nil, action: nil)
    }

    func icon(from network: CardNetwork?) -> UIImage? {
        switch network {
        case .amex?:
            return .imageFromPodBundle("american_express")
        case .mastercard?:
            return .imageFromPodBundle("mastercard")
        case .visa?:
            return .imageFromPodBundle("visa")
        case .discover?:
            return .imageFromPodBundle("discover")
        default:
            return .imageFromPodBundle("credit_debit_card")
        }
    }
}
