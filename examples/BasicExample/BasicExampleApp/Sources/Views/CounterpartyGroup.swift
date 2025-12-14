import Candle
import SwiftUI

struct CounterpartyGroup: View {

    let counterparty: Candle.Models.Counterparty

    var body: some View {
        DisclosureGroup {
            switch counterparty {
            case .MerchantCounterparty(let merchantCounterparty):
                Section(header: Text("Details").bold()) {
                    if let location = merchantCounterparty.location {
                        InfoRow(
                            symbol: .globe,  // FIXME: Grab flag of country code
                            title: "Country Code",
                            value: location.countryCode,
                        )
                        InfoRow(
                            symbol: .globe,
                            title: "Country Subdivision Code",
                            value: location.countrySubdivisionCode,
                        )
                        InfoRow(
                            symbol: .globe,
                            title: "Locality Name",
                            value: location.localityName,
                        )
                    }
                }

            case .ServiceCounterparty: Spacer()
            case .UserCounterparty(let userCounterparty):
                Section(header: Text("Details").bold()) {
                    InfoRow(symbol: .person, title: "Username", value: userCounterparty.username)
                }
            }
        } label: {
            switch counterparty {
            case .MerchantCounterparty(let merchantCounterparty):
                InfoHeader(
                    logo: .url(URL(string: merchantCounterparty.logoURL)),
                    title: merchantCounterparty.name,
                    badges: [counterparty.badge],
                )
            case .ServiceCounterparty(let serviceCounterparty):
                InfoHeader(
                    logo: .url(serviceCounterparty.service.logoURL),
                    title: serviceCounterparty.service.description,
                    badges: [counterparty.badge],
                )
            case .UserCounterparty(let userCounterparty):
                InfoHeader(
                    logo: .url(URL(string: userCounterparty.avatarURL)),
                    title: userCounterparty.legalName,
                    badges: [counterparty.badge],
                )
            }
        }
    }
}
