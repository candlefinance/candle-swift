import Candle
import MapKit
import SwiftUI

struct TransportAssetFormViewModel: Observable {
    var quoteRequest: Candle.Models.TransportAssetQuoteRequest

    var serviceAccountID: String {
        get { quoteRequest.serviceAccountID ?? "" }
        set { quoteRequest.serviceAccountID = newValue.isEmpty ? nil : newValue }
    }

    var originCoordinates: CLLocationCoordinate2D {
        get {
            quoteRequest.originCoordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            } ?? CLLocationCoordinate2D()
        }
        set {
            let newCoordinates = Candle.Models.Coordinates(
                latitude: newValue.latitude.rounded(to: 6),
                longitude: newValue.longitude.rounded(to: 6)
            )
            quoteRequest.originCoordinates =
                newCoordinates.latitude == 0 && newCoordinates.longitude == 0 ? nil : newCoordinates
        }
    }

    var formattedOriginCoordinates: String {
        return "\(originCoordinates.latitude), \(originCoordinates.longitude)"
    }

    var destinationCoordinates: CLLocationCoordinate2D {
        get {
            quoteRequest.destinationCoordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            } ?? CLLocationCoordinate2D()
        }
        set {
            let newCoordinates = Candle.Models.Coordinates(
                latitude: newValue.latitude.rounded(to: 6),
                longitude: newValue.longitude.rounded(to: 6)
            )
            quoteRequest.destinationCoordinates =
                newCoordinates.latitude == 0 && newCoordinates.longitude == 0 ? nil : newCoordinates
        }
    }

    var formattedDestinationCoordinates: String {
        "\(destinationCoordinates.latitude), \(destinationCoordinates.longitude)"
    }
}

struct TransportAssetForm: View {

    @Binding var viewModel: TransportAssetFormViewModel
    @State var locationProvider = LocationViewModel()
    @State private var originCamera: MapCameraPosition = .region(
        .init(center: .init(), latitudinalMeters: 100_000_000, longitudinalMeters: 100_000_000)
    )
    @State private var destinationCamera: MapCameraPosition = .region(
        .init(center: .init(), latitudinalMeters: 100_000_000, longitudinalMeters: 100_000_000)
    )

    var body: some View {
        // FIXME: Accept input for asset ID, seats, and addresses

        // FIXME: Show drop-down menu of known accounts
        FormRow(
            value: $viewModel.serviceAccountID,
            title: "Service Account ID",
            placeholder: "optional"
        )
        .onAppear { locationProvider.requestLocation() }

        VStack {
            HStack {
                Text("Origin").fontWeight(.bold)
                Spacer()
                Text(viewModel.formattedOriginCoordinates)
                    .foregroundStyle(
                        viewModel.quoteRequest.originCoordinates == nil ? .tertiary : .primary
                    )
            }
            Map(position: $originCamera) {
                Marker("", coordinate: viewModel.originCoordinates).tint(.green)
            }
            .onMapCameraChange(frequency: .continuous) { context in
                viewModel.originCoordinates = context.region.center
            }
            .frame(height: 200).cornerRadius(10)
        }
        .onChange(of: locationProvider.coordinate) { oldValue, newValue in
            guard let newValue else { return }
            viewModel.originCoordinates = newValue
            originCamera = .region(
                .init(center: newValue, latitudinalMeters: 2_000, longitudinalMeters: 2_000)
            )
        }

        VStack {
            HStack {
                Text("Destination").fontWeight(.bold)
                Spacer()
                Text(viewModel.formattedDestinationCoordinates)
                    .foregroundStyle(
                        viewModel.quoteRequest.destinationCoordinates == nil ? .tertiary : .primary
                    )
            }
            Map(position: $destinationCamera) {
                Marker("", coordinate: viewModel.destinationCoordinates).tint(.red)
            }
            .onMapCameraChange(frequency: .continuous) { context in
                viewModel.destinationCoordinates = context.region.center
            }
            .frame(height: 200).cornerRadius(10)
        }
        .onChange(of: locationProvider.coordinate) { oldValue, newValue in
            guard let newValue else { return }
            viewModel.destinationCoordinates = newValue
            destinationCamera = .region(
                .init(center: newValue, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
            )
        }
    }
}
