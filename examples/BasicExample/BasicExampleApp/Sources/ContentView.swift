import Candle
import SFSafeSymbols
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

        var symbol: SFSymbol {
            switch self {
            case .services: .person2
            case .accounts: .buildingColumns
            case .trades: .arrowLeftArrowRight
            }
        }
    }

    @State var selectedTab: AppTab = .services
    @State var linkedAccounts: [Candle.Models.LinkedAccount] = []
    @State var assetAccounts: [Candle.Models.AssetAccount] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                NavigationStack {
                    switch tab {
                    case .services: LinkedAccountsScreen(linkedAccounts: $linkedAccounts)
                    case .accounts:
                        AssetAccountsScreen(
                            assetAccounts: $assetAccounts,
                            linkedAccounts: linkedAccounts
                        )
                    case .trades:
                        TradesScreen(linkedAccounts: linkedAccounts, assetAccounts: assetAccounts)
                    }
                }
                .tabItem { Label(tab.title, systemSymbol: tab.symbol) }.tag(tab)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

#Preview { ContentView() }
