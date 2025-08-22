import Candle
import SwiftUI

struct FiatAssetFormViewModel: Observable {
    var quoteRequest: Models.FiatAssetQuoteRequest

    var serviceAccountID: String {
        get { quoteRequest.serviceAccountID ?? "" }
        set { quoteRequest.serviceAccountID = newValue.isEmpty ? nil : newValue }
    }

    var currencyCode: String {
        get { quoteRequest.currencyCode ?? "" }
        set { quoteRequest.currencyCode = newValue.isEmpty ? nil : newValue }
    }

    var amount: String {
        get { quoteRequest.amount?.formatted() ?? "" }
        set { quoteRequest.amount = Double(newValue) }
    }
}

struct FiatAssetForm: View {

    @Binding var viewModel: FiatAssetFormViewModel

    var body: some View {
        // FIXME: Show drop-down menu of known accounts
        FormRow(
            value: $viewModel.serviceAccountID,
            title: "Service Account ID",
            placeholder: "optional"
        )

        // FIXME: Show drop-down menu of known currencies
        FormRow(value: $viewModel.currencyCode, title: "Currency Code", placeholder: "optional")

        // FIXME: Format amount with selected currency
        FormRow(value: $viewModel.amount, title: "Amount", placeholder: "optional")
    }
}
