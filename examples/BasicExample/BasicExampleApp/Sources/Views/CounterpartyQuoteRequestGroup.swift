import Candle
import SwiftUI

struct CounterpartyQuoteRequestGroup: View {

    @Binding var counterpartyQuoteRequest: Candle.Models.CounterpartyQuoteRequest

    var body: some View {
        switch counterpartyQuoteRequest {
        case .user(var userCounterpartyQuoteRequest):
            // FIXME: Show drop-down menu of known friends
            FormTextRow(
                value: Binding(
                    get: { userCounterpartyQuoteRequest.legalName ?? "" },
                    set: {
                        userCounterpartyQuoteRequest.legalName = $0.isEmpty ? nil : $0
                        counterpartyQuoteRequest = .user(userCounterpartyQuoteRequest)
                    }
                ),
                symbol: .signature,
                title: "Legal Name",
                placeholder: "Automatic"
            )

            // FIXME: Show drop-down menu of known friends
            FormTextRow(
                value: Binding(
                    get: { userCounterpartyQuoteRequest.username ?? "" },
                    set: {
                        userCounterpartyQuoteRequest.username = $0.isEmpty ? nil : $0
                        counterpartyQuoteRequest = .user(userCounterpartyQuoteRequest)
                    }
                ),
                symbol: .person,
                title: "Username",
                placeholder: "Required"
            )

        case .merchant(var merchantCounterpartyQuoteRequest):
            // FIXME: Show drop-down menu of previously used businesses
            FormTextRow(
                value: Binding(
                    get: { merchantCounterpartyQuoteRequest.name ?? "" },
                    set: {
                        merchantCounterpartyQuoteRequest.name = $0.isEmpty ? nil : $0
                        counterpartyQuoteRequest = .merchant(merchantCounterpartyQuoteRequest)
                    }
                ),
                symbol: .tag,
                title: "Name",
                placeholder: "Required"
            )

        // FIXME: Placeholder text label
        case .service: Spacer()
        }
    }
}
