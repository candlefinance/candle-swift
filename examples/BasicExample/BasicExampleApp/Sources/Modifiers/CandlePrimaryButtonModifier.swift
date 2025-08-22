import SwiftUI

@available(macOS 14, iOS 17.0, *) struct CandlePrimaryButtonModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    let color: Color?
    let size: CGFloat
    let fontSize: CGFloat

    var defaultColor: Color { colorScheme == .dark ? .white : .black }

    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
        .foregroundColor(.white).frame(height: size)
        .background(
            RoundedRectangle(cornerRadius: size / 2, style: .continuous).fill(color ?? defaultColor)
        )
        .font(.system(size: fontSize)).fontDesign(.rounded).bold()
    }
}

extension View {
    @available(macOS 14, iOS 17.0, *) func candlePrimaryButtonStyle(
        color: Color? = nil,
        size: CGFloat = 48,
        fontSize: CGFloat = 19
    ) -> some View {
        modifier(CandlePrimaryButtonModifier(color: color, size: size, fontSize: fontSize))
    }
}
