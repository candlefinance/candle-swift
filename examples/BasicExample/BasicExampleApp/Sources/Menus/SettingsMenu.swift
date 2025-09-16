import SwiftUI

struct SettingsMenu: View {

    @Binding var showDeleteConfirmation: Bool
    @Binding var showSDKVersion: Bool

    var body: some View {
        Menu {
            Button(action: { showDeleteConfirmation = true }) {
                Label("Delete User", systemImage: "person.slash")
            }
            Button(action: { showSDKVersion = true }) {
                Label("Show Candle Version", systemImage: "info.circle")
            }
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
}

#Preview {
    SettingsMenu(showDeleteConfirmation: .constant(false), showSDKVersion: .constant(false))
}
