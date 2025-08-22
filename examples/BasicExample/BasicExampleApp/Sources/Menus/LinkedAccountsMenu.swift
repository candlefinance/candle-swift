import Candle
import SwiftUI

struct LinkedAccountsMenu: View {
    @Environment(CandleClient.self) private var client

    let linkedAccounts: [Models.LinkedAccount]

    @Binding var selectedLinkedAccountIDs: [Models.LinkedAccountID]

    var body: some View {
        Menu("Linked Accounts") {
            ForEach(linkedAccounts) { (linkedAccount: Models.LinkedAccount) in
                Button(action: {
                    if let index = selectedLinkedAccountIDs.firstIndex(
                        of: linkedAccount.linkedAccountID
                    ) {
                        selectedLinkedAccountIDs.remove(at: index)
                    } else {
                        selectedLinkedAccountIDs.append(linkedAccount.linkedAccountID)
                    }
                }) {
                    Label(
                        "\(linkedAccount.service.description) (\(linkedAccount.formattedSubtitle))",
                        systemImage: selectedLinkedAccountIDs.contains(linkedAccount.id)
                            ? "checkmark" : ""
                    )
                }
            }
        }
    }
}
