import Candle
import SwiftUI

struct OnboardingScreen: View {

    @Environment(\.dismiss) private var dismiss

    // FIXME: Collect this value from the user
    @State private var username: String = ""
    @State private var error: (title: String, message: String)?

    @State private var prVisible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var previousOffset: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var isDragging = false
    @State var photos: [ItemPhoto.Photo]

    let title: String
    let product: String
    let caption: String
    let ctaText: String

    private let imageWidth: CGFloat = 219
    private let spacing: CGFloat = 30

    var currentIndex: Int {
        let totalWidth = imageWidth + spacing
        let rawIndex = Int((-scrollOffset + totalWidth / 2) / totalWidth)
        return max(0, min(rawIndex, photos.count - 1))
    }

    var body: some View {
        ZStack {
            Image(photos[currentIndex].resource).resizable().ignoresSafeArea(.all).blur(radius: 10)
            VStack {
                pagingRotation.transition(.move(edge: .top))
                    .animation(.easeInOut(duration: 1), value: prVisible)
                cta
                Spacer()
            }
            .background(.black.opacity(0.65)).background(.ultraThinMaterial)
            .sensoryFeedback(.selection, trigger: isDragging ? currentIndex : nil)
            .alert(isPresented: .constant(error != nil)) {
                Alert(
                    title: Text(error!.title),
                    message: Text(error!.message),
                    dismissButton: .cancel(Text("OK"), action: { error = nil })
                )
            }
        }
    }

    @ViewBuilder var pagingRotation: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                        ItemPhoto(photo: photo).frame(width: imageWidth)
                            .scrollTransition(axis: .horizontal) { content, phase in
                                content.rotationEffect(.degrees(phase.value * 2.5))
                                    .scaleEffect(1 - abs(phase.value) * 0.025)
                                    .opacity(1 - abs(phase.value) * 0.8)
                            }
                    }
                }
                .offset(x: scrollOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            timer?.invalidate()
                            if !isDragging {
                                previousOffset = scrollOffset
                                isDragging = true
                            }
                            scrollOffset = previousOffset + value.translation.width
                        }
                        .onEnded { value in
                            let imageWidth: CGFloat = imageWidth + spacing
                            let predictedIndex = Int(
                                round(
                                    -(scrollOffset + value.predictedEndTranslation.width)
                                        / imageWidth
                                )
                            )
                            withAnimation(.easeOut) {
                                scrollOffset = -CGFloat(predictedIndex) * imageWidth
                            }
                            previousOffset = scrollOffset

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isDragging = false
                                startAutoScroll(geometry.size.width)
                            }
                        }
                )
                .onAppear { startAutoScroll(geometry.size.width) }
                .onDisappear {
                    timer?.invalidate()
                    prVisible = false
                    ctaVisible = false
                }
                .onChange(of: currentIndex) { _, newIndex in
                    withAnimation(nil) {
                        if newIndex >= photos.count - 3 { self.photos.append(contentsOf: photos) }
                    }
                }
            }
            .contentMargins(.extraLarge).frame(height: UIScreen.main.bounds.height * 0.55)
        }
        .frame(height: UIScreen.main.bounds.height * 0.55).padding(.vertical, .extraLarge)
    }

    func startAutoScroll(_ viewWidth: CGFloat) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            Task { @MainActor in
                withAnimation {
                    scrollOffset -= 1
                    if scrollOffset <= -viewWidth * CGFloat(photos.count - 1) { scrollOffset = 0 }
                }
            }
        }
    }

    private var titleText: some View {
        Text(title).font(.system(size: .large, weight: .bold, design: .default))
            .foregroundStyle(.secondary)
    }

    private var productText: some View {
        Text(product).font(.system(size: .extraHuge, weight: .bold, design: .default))
            .customAttribute(EmphasisAttribute()).padding(.bottom, 5)
    }

    private var captionText: some View {
        Text(caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
    }

    var cta: some View {
        VStack {
            if ctaVisible {
                if #available(iOS 18.0, *) {
                    titleText.transition(TextTransition())
                } else {
                    titleText
                }
                if #available(iOS 18.0, *) {
                    productText.transition(TextTransition())
                } else {
                    productText
                }
                if #available(iOS 18.0, *) {
                    captionText.transition(TextTransition())
                } else {
                    captionText
                }
                Spacer(minLength: .extraLarge)
                Button(action: {
                    Task {
                        if await createUser() { dismiss() }
                    }
                }) {
                    Text(ctaText).font(.system(size: 15, weight: .semibold, design: .default))
                        .padding([.vertical], .medium).padding([.horizontal], .large)
                }
                .buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(.white)
                .foregroundStyle(.black).padding(.extraLarge)
            }
        }
        .foregroundStyle(.white).padding()
        .onAppear {
            withAnimation(.bouncy(duration: 0.5)) {
                prVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { ctaVisible = true }
            }
        }
    }
    private func createUser() async -> Bool {
        do {
            try await Candle.Client.shared.createUser(appUserID: username)
            return true
        } catch {
            switch error {
            case .existingActiveUser:
                self.error = (title: "Existing Active User", message: "Delete user first.")
                return true
            case .createSessionError:
                self.error = (title: "Create Session Error", message: "Contact Candle support.")
            case .keychainError:
                self.error = (title: "Keychain Error", message: "Double-check your access group.")
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_app: self.error = (title: "App Not Found", message: payload.message)
                }
            case .unprocessableContent(let payload):
                switch payload.kind {
                case .schemaInvalid_request:
                    self.error = (title: "Request Schema Invalid", message: payload.message)
                }
            case .unauthorized(let payload):
                switch payload.kind {
                case .badAuthorization_app:
                    self.error = (title: "Bad App Authorization", message: payload.message)
                }
            case .forbidden(let payload):
                switch payload.kind {
                case .disabledPendingPayment_app:
                    self.error = (title: "App Disabled Pending Payment", message: payload.message)
                }
            case .tooManyRequests(let payload):
                switch payload.kind {
                case .overUserLimit_app:
                    self.error = (title: "App Over User Limit", message: payload.message)
                }
            case .internalServerError(let payload):
                switch payload.kind {
                case .unexpected:
                    self.error = (title: "Internal Server Error", message: payload.message)
                }
            case .unexpectedStatusCode(let statusCode):
                self.error = (
                    title: "Unexpected Status Code", message: "Received \(statusCode) response"
                )
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            }
            return false
        }
    }
}

#Preview {
    OnboardingScreen(
        photos: [
            .init(resource: .link1), .init(resource: .link2), .init(resource: .link3),
            .init(resource: .link4), .init(resource: .link5),
        ],
        title: "Welcome to",
        product: "Candle",
        caption: "This example app lets you explore the SDK functionality.",
        ctaText: "Get Started"
    )
}
