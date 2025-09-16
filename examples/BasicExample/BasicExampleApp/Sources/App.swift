import Candle
import SwiftUI

@main struct App: SwiftUI.App {

    var body: some Scene { WindowGroup { ContentView() } }

    init() {
        do {
            #warning("Add your Candle app key and secret here (https://platform.candle.fi)")
            try Candle.Client.initialize(appKey: <#YOUR_APP_KEY#>, appSecret: <#YOUR_APP_SECRET_KEY#>)
        } catch {
            switch error {
            case .alreadyInitialized: fatalError("Already Initialized")
            case .createSessionError: fatalError("Create Session Error")
            case .startMonitoringError: fatalError("Start Monitoring Error")
            case .keychainError: fatalError("Keychain Error")
            }
        }
    }
}
