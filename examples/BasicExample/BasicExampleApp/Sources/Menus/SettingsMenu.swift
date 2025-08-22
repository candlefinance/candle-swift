import SwiftUI

struct SettingsMenu: View {

    @Binding var showOnboarding: Bool
    @Binding var showDeleteConfirmation: Bool
    @Binding var showSDKVersion: Bool

    var body: some View {
        Menu {
            Button(action: { showOnboarding = true }) {
                Label("Show Onboarding", systemImage: "platter.filled.bottom.iphone")
            }
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
    SettingsMenu(
        showOnboarding: .constant(false),
        showDeleteConfirmation: .constant(false),
        showSDKVersion: .constant(false)
    )
}
