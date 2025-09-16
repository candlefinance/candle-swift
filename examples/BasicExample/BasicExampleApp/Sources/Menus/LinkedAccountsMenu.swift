import Candle
import SwiftUI

struct LinkedAccountsMenu: View {
    let linkedAccounts: [Candle.Models.LinkedAccount]

    @Binding var selectedLinkedAccountIDs: [Candle.Models.LinkedAccountID]

    var body: some View {
        Menu("Linked Accounts") {
            ForEach(linkedAccounts) { (linkedAccount: Candle.Models.LinkedAccount) in
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
