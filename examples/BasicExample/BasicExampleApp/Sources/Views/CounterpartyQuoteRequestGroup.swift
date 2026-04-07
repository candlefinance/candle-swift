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
                placeholder: "Automatic"
            )
            FormTextRow(
                value: Binding(
                    get: { merchantCounterpartyQuoteRequest.location?.localityName ?? "" },
                    set: {
                        merchantCounterpartyQuoteRequest.location =
                            ($0.isEmpty
                                && (merchantCounterpartyQuoteRequest.location?.countryCode ?? "")
                                    .isEmpty
                                && (merchantCounterpartyQuoteRequest.location?
                                    .countrySubdivisionCode ?? "")
                                    .isEmpty)
                            ? nil
                            : .init(
                                countryCode: merchantCounterpartyQuoteRequest.location?.countryCode
                                    ?? "",
                                countrySubdivisionCode: merchantCounterpartyQuoteRequest.location?
                                    .countrySubdivisionCode ?? "",
                                localityName: $0
                            )
                        counterpartyQuoteRequest = .merchant(merchantCounterpartyQuoteRequest)
                    }
                ),
                symbol: .mappinAndEllipse,
                title: "Locality",
                placeholder: "Required"
            )
            FormTextRow(
                value: Binding(
                    get: {
                        merchantCounterpartyQuoteRequest.location?.countrySubdivisionCode ?? ""
                    },
                    set: {
                        merchantCounterpartyQuoteRequest.location =
                            ($0.isEmpty
                                && (merchantCounterpartyQuoteRequest.location?.countryCode ?? "")
                                    .isEmpty
                                && (merchantCounterpartyQuoteRequest.location?.localityName ?? "")
                                    .isEmpty)
                            ? nil
                            : .init(
                                countryCode: merchantCounterpartyQuoteRequest.location?.countryCode
                                    ?? "",
                                countrySubdivisionCode: $0.uppercased(),
                                localityName: merchantCounterpartyQuoteRequest.location?
                                    .localityName ?? ""
                            )
                        counterpartyQuoteRequest = .merchant(merchantCounterpartyQuoteRequest)
                    }
                ),
                symbol: .map,
                title: "State/Province Code",
                placeholder: "Required"
            )
            FormTextRow(
                value: Binding(
                    get: { merchantCounterpartyQuoteRequest.location?.countryCode ?? "" },
                    set: {
                        merchantCounterpartyQuoteRequest.location =
                            ($0.isEmpty
                                && (merchantCounterpartyQuoteRequest.location?
                                    .countrySubdivisionCode ?? "")
                                    .isEmpty
                                && (merchantCounterpartyQuoteRequest.location?.localityName ?? "")
                                    .isEmpty)
                            ? nil
                            : .init(
                                countryCode: $0.uppercased(),
                                countrySubdivisionCode: merchantCounterpartyQuoteRequest.location?
                                    .countrySubdivisionCode ?? "",
                                localityName: merchantCounterpartyQuoteRequest.location?
                                    .localityName ?? ""
                            )
                        counterpartyQuoteRequest = .merchant(merchantCounterpartyQuoteRequest)
                    }
                ),
                symbol: .globe,
                title: "Country Code",
                placeholder: "Required"
            )

        // FIXME: Placeholder text label
        case .service: Spacer()
        }
    }
}
