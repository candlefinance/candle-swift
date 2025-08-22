import Candle
import SwiftUI

@main struct App: SwiftUI.App {
    #warning("Add your Candle app key and secret here (https://platform.candle.fi)")
    let user = Models.AppUser(appKey: <#YOUR_APP_KEY#>, appSecret: <#YOUR_APP_SECRET_KEY#>)

    var body: some Scene { WindowGroup { ContentView().environment(CandleClient(appUser: user)) } }
}
