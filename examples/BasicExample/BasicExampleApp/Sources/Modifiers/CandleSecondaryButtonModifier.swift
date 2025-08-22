import SwiftUI

@available(macOS 14, iOS 17.0, *) struct CandleSecondaryButtonModifier: ViewModifier {
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
        .foregroundColor(color ?? defaultColor).frame(height: size)
        .background(
            RoundedRectangle(cornerRadius: size / 2, style: .continuous)
                .stroke(color ?? defaultColor, lineWidth: .xSmall)
        )
        .font(.system(size: fontSize)).fontDesign(.rounded).bold()
    }
}

extension View {
    @available(macOS 14, iOS 17.0, *) func candleSecondaryButtonStyle(
        color: Color? = nil,
        size: CGFloat = 48,
        fontSize: CGFloat = 19
    ) -> some View {
        modifier(CandleSecondaryButtonModifier(color: color, size: size, fontSize: fontSize))
    }
}
