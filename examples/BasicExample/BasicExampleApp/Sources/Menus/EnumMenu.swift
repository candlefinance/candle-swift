import Candle
import SwiftUI

struct EnumMenu<EnumType>: View
where
    EnumType: CaseIterable, EnumType: RawRepresentable, EnumType.RawValue == String,
    EnumType: CustomStringConvertible, EnumType.AllCases: RandomAccessCollection, EnumType: Hashable
{
    let name: String
    @Binding var selectedCase: EnumType?

    var body: some View {
        Menu(name) {
            ForEach(EnumType.allCases, id: \.self) { enumCase in
                Button(action: {
                    if selectedCase == enumCase {
                        selectedCase = nil
                    } else {
                        selectedCase = enumCase
                    }
                }) {
                    Label {
                        Text(enumCase.description)
                    } icon: {
                        if selectedCase == enumCase { Image(systemSymbol: .checkmark) }
                    }
                }
            }
        }
    }
}
