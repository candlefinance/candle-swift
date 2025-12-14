import MapKit
import SFSafeSymbols
import SwiftUI

struct FormCoordinatesDetails: View {
    @Binding var value: CLLocationCoordinate2D

    @State var locationProvider = LocationProvider()
    @State private var camera: MapCameraPosition

    let markerTitle: String
    let markerColor: Color

    init(value: Binding<CLLocationCoordinate2D>, markerTitle: String, markerColor: Color) {
        self.markerTitle = markerTitle
        self.markerColor = markerColor

        self._value = value

        let valueIsSet = value.wrappedValue.latitude != 0 && value.wrappedValue.longitude != 0
        self.camera = .region(
            .init(
                center: value.wrappedValue,
                latitudinalMeters: valueIsSet ? 2_000 : 100_000_000,
                longitudinalMeters: valueIsSet ? 2_000 : 100_000_000
            )
        )
    }

    var body: some View {
        Map(position: $camera) { Marker(markerTitle, coordinate: value).tint(markerColor) }
            .onMapCameraChange(frequency: .continuous) { context in value = context.region.center }
            .onChange(of: locationProvider.coordinate) { oldValue, newValue in
                guard let newValue else { return }
                value = newValue
                camera = .region(
                    .init(center: newValue, latitudinalMeters: 2_000, longitudinalMeters: 2_000)
                )
            }
            .navigationTitle("Coordinates")
            .onAppear {
                print("COORDINATES DETAILS APPEARED")
                if value.latitude == 0 && value.longitude == 0 {
                    locationProvider.requestLocation()
                }
            }
    }
}

struct FormCoordinatesRow: View {
    @Binding var value: CLLocationCoordinate2D
    @State var showDetails: Bool = false

    let symbol: SFSymbol
    let title: String
    let placeholder: String

    let markerTitle: String
    let markerColor: Color

    var formattedCoordinates: String? {
        value.latitude == 0 && value.longitude == 0 ? nil : "\(value.latitude), \(value.longitude)"
    }

    var body: some View {
        NavigationLink {
            FormCoordinatesDetails(
                value: $value,
                markerTitle: markerTitle,
                markerColor: markerColor
            )
        } label: {
            Image(systemSymbol: symbol).frame(width: 24).foregroundColor(.accentColor)

            Text(title).fontWeight(.bold)
            Spacer()

            if let formattedCoordinates {
                Text(formattedCoordinates).frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text(placeholder).foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
