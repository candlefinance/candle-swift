import Foundation
import SFSafeSymbols
import SwiftUI

enum Logo {
    case url(URL?)
    case symbol(SFSymbol, Color)
    case text(String, Color)
}
