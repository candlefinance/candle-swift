import Candle
import SwiftUI

struct LinkedAccountsMenu: View {
    @Environment(CandleClient.self) private var client

    let linkedAccounts: [Models.LinkedAccount]

    var linkedAccountViewModels: [LinkedAccountViewModel] {
        linkedAccounts.map { LinkedAccountViewModel(client: client, linkedAccount: $0) }
    }

    @Binding var selectedLinkedAccountIDs: [Models.LinkedAccountID]

    var body: some View {
        Menu("Linked Accounts") {
            ForEach(linkedAccountViewModels) { linkedAccount in
                Button(action: {
                    if let index = selectedLinkedAccountIDs.firstIndex(of: linkedAccount.id) {
                        selectedLinkedAccountIDs.remove(at: index)
                    } else {
                        selectedLinkedAccountIDs.append(linkedAccount.id)
                    }
                }) {
                    Label(
                        "\(linkedAccount.title) (\(linkedAccount.subtitle))",
                        systemImage: selectedLinkedAccountIDs.contains(linkedAccount.id)
                            ? "checkmark" : ""
                    )
                }
            }
        }
    }
}
