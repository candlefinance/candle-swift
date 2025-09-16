import Candle
import SwiftUI

struct ContentView: View {

    enum AppTab: Int, CaseIterable {
        case services, accounts, trades

        var title: String {
            switch self {
            case .services: "Services"
            case .accounts: "Accounts"
            case .trades: "Trades"
            }
        }

        var systemImage: String {
            switch self {
            case .services: "person.2"
            case .accounts: "building.columns"
            case .trades: "arrow.left.arrow.right"
            }
        }
    }

    @State var selectedTab: AppTab = .services
    @State var linkedAccounts: [Candle.Models.LinkedAccount] = []

    @State var error: (title: String, message: String)? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                NavigationStack {
                    switch tab {
                    case .services:
                        LinkedAccountsScreen(linkedAccounts: $linkedAccounts, error: $error)
                    case .accounts:
                        AssetAccountsScreen(error: $error, linkedAccounts: linkedAccounts)
                    case .trades: TradesScreen(error: $error, linkedAccounts: linkedAccounts, )
                    }
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }.tag(tab)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text(error!.title),
                message: Text(error!.message),
                dismissButton: .cancel(Text("OK"), action: { error = nil })
            )
        }
    }
}

#Preview { ContentView() }
