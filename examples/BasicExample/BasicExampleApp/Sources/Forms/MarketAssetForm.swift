import Candle
import SwiftUI

struct MarketAssetFormViewModel: Observable {
    var quoteRequest: Candle.Models.MarketAssetQuoteRequest

    var serviceAccountID: String {
        get { quoteRequest.serviceAccountID ?? "" }
        set { quoteRequest.serviceAccountID = newValue.isEmpty ? nil : newValue }
    }

    var symbol: String {
        get { quoteRequest.symbol ?? "" }
        set { quoteRequest.symbol = newValue.isEmpty ? nil : newValue }
    }

    var amount: String {
        get { quoteRequest.amount?.formatted() ?? "" }
        set { quoteRequest.amount = Double(newValue) }
    }
}

struct MarketAssetForm: View {

    @Binding var viewModel: MarketAssetFormViewModel

    var body: some View {
        // FIXME: Accept for input for asset ID

        // FIXME: Show drop-down menu of known accounts
        FormRow(
            value: $viewModel.serviceAccountID,
            title: "Service Account ID",
            placeholder: "optional"
        )

        // FIXME: Show drop-down menu of known currencies
        FormRow(value: $viewModel.symbol, title: "Symbol", placeholder: "optional")

        // FIXME: Format amount with selected currency
        FormRow(value: $viewModel.amount, title: "Amount", placeholder: "optional")
    }
}
