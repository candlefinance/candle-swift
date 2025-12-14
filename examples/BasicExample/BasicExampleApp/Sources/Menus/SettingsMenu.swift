import SwiftUI

struct SettingsMenu: View {

    @Binding var showDeleteConfirmation: Bool
    @Binding var showSDKVersion: Bool

    var body: some View {
        Menu {
            Button(action: { showDeleteConfirmation = true }) {
                Label("Delete User", systemSymbol: .personSlash)
            }
            Button(action: { showSDKVersion = true }) {
                Label("Show Candle Version", systemSymbol: .infoCircle)
            }
        } label: {
            Label("Settings", systemSymbol: .gear)
        }
    }
}

#Preview {
    SettingsMenu(showDeleteConfirmation: .constant(false), showSDKVersion: .constant(false))
}
