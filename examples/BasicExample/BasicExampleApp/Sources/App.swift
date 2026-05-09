import Candle
import SwiftUI

@main struct App: SwiftUI.App {

    var body: some Scene { WindowGroup { ContentView() } }

    init() {
        do throws(Candle.Client.InitializationError) {
            #warning("Add your Candle client ID here (https://platform.candle.fi)")
            try Candle.Client.initialize(clientID: <#YOUR_CLIENT_ID#>)
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
