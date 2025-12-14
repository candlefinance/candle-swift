import Candle
import Foundation
import MapKit
import SwiftUI

struct TradeAssetQuoteRequestGroup: View {

    @Binding var tradeAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest
    let assetAccounts: [Candle.Models.AssetAccount]

    var body: some View {
        switch tradeAssetQuoteRequest {
        case .FiatAssetQuoteRequest(var fiatAssetQuoteRequest):
            // FIXME: Add drop-down menu for currency and format amount using it
            FormChoiceRow(
                selectedValueID: Binding(
                    get: { fiatAssetQuoteRequest.currencyCode },
                    set: {
                        fiatAssetQuoteRequest.currencyCode = $0
                        tradeAssetQuoteRequest = .FiatAssetQuoteRequest(fiatAssetQuoteRequest)
                    }
                ),
                allowedValues: Locale.Currency.activeCurrencies.map {
                    .init(
                        id: $0.identifier,
                        description: Locale.current.localizedString(forCurrencyCode: $0.identifier)
                            ?? "USD",
                        logo: .text(
                            Locale.current.localizedSymbol(forCurrencyCode: $0.identifier),
                            .assetKindFiat
                        )
                    )
                },
                symbol: .dollarsignCircle,
                title: "Currency",
                placeholder: "Automatic",
            )
            FormNumberRow(
                value: Binding(
                    get: { fiatAssetQuoteRequest.amount },
                    set: {
                        fiatAssetQuoteRequest.amount = $0
                        tradeAssetQuoteRequest = .FiatAssetQuoteRequest(fiatAssetQuoteRequest)
                    }
                ),
                symbol: .banknote,
                title: "Amount",
                placeholder: "Automatic",
                format: .number
            )

            FormChoiceRow(
                selectedValueID: Binding(
                    get: { fiatAssetQuoteRequest.serviceAccountID },
                    set: {
                        fiatAssetQuoteRequest.serviceAccountID = $0
                        tradeAssetQuoteRequest = .FiatAssetQuoteRequest(fiatAssetQuoteRequest)
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .FiatAccount(let fiatAccount) = $0 else { return nil }
                    return .init(
                        id: fiatAccount.serviceAccountID,
                        description: fiatAccount.nickname,
                        logo: .url(fiatAccount.service.logoURL)
                    )
                },
                symbol: .buildingColumns,
                title: "Service Account",
                placeholder: "Automatic",
            )

        case .MarketAssetQuoteRequest(var marketAssetQuoteRequest):
            // FIXME: Show color + logoURL
            FormTextRow(
                value: Binding(
                    get: { marketAssetQuoteRequest.symbol ?? "" },
                    set: {
                        marketAssetQuoteRequest.symbol = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .MarketAssetQuoteRequest(marketAssetQuoteRequest)
                    }
                ),
                symbol: .chartLineUptrendXyaxis,
                title: "Symbol",
                placeholder: "Required",
            )
            FormNumberRow(
                value: Binding(
                    get: { marketAssetQuoteRequest.amount },
                    set: {
                        marketAssetQuoteRequest.amount = $0
                        tradeAssetQuoteRequest = .MarketAssetQuoteRequest(marketAssetQuoteRequest)
                    }
                ),
                symbol: .banknote,
                title: "Amount",
                placeholder: "Automatic",
                format: .number
            )

            // FIXME: Show drop-down menu of known assets
            FormTextRow(
                value: Binding(
                    get: { marketAssetQuoteRequest.serviceAssetID ?? "" },
                    set: {
                        marketAssetQuoteRequest.serviceAssetID = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .MarketAssetQuoteRequest(marketAssetQuoteRequest)
                    }
                ),
                symbol: .diamond,
                title: "Service Asset ID",
                placeholder: "Automatic",
            )

            FormChoiceRow(
                selectedValueID: Binding(
                    get: { marketAssetQuoteRequest.serviceAccountID },
                    set: {
                        marketAssetQuoteRequest.serviceAccountID = $0
                        tradeAssetQuoteRequest = .MarketAssetQuoteRequest(marketAssetQuoteRequest)
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .MarketAccount(let marketAccount) = $0,
                        marketAccount.assetKind.rawValue
                            == marketAssetQuoteRequest.assetKind.rawValue
                    else { return nil }
                    return .init(
                        id: marketAccount.serviceAccountID,
                        description: marketAccount.nickname,
                        logo: .url(marketAccount.service.logoURL)
                    )
                },
                symbol: .buildingColumns,
                title: "Service Account",
                placeholder: "Automatic",
            )

        case .TransportAssetQuoteRequest(var transportAssetQuoteRequest):
            Section(header: Text("Origin")) {
                FormCoordinatesRow(
                    value: Binding(
                        get: {
                            transportAssetQuoteRequest.originCoordinates.map {
                                CLLocationCoordinate2D(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude
                                )
                            } ?? CLLocationCoordinate2D()
                        },
                        set: {
                            let newCoordinates = Candle.Models.Coordinates(
                                latitude: $0.latitude.rounded(to: 6),
                                longitude: $0.longitude.rounded(to: 6)
                            )
                            transportAssetQuoteRequest.originCoordinates =
                                newCoordinates.latitude == 0 && newCoordinates.longitude == 0
                                ? nil : newCoordinates
                            tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                                transportAssetQuoteRequest
                            )
                        }
                    ),
                    symbol: .sunrise,
                    title: "Coordinates",
                    placeholder: "Required",
                    markerTitle: "Origin",
                    markerColor: .green
                )
                FormTextRow(
                    value: Binding(
                        get: { transportAssetQuoteRequest.originAddress?.value ?? "" },
                        set: {
                            transportAssetQuoteRequest.originAddress =
                                $0.isEmpty ? nil : .init(value: $0)
                            tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                                transportAssetQuoteRequest
                            )
                        }
                    ),
                    symbol: .sunrise,
                    title: "Address",
                    placeholder: "Automatic",
                )
            }
            Section(header: Text("Destination")) {
                FormCoordinatesRow(
                    value: Binding(
                        get: {
                            transportAssetQuoteRequest.destinationCoordinates.map {
                                CLLocationCoordinate2D(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude
                                )
                            } ?? CLLocationCoordinate2D()
                        },
                        set: {
                            let newCoordinates = Candle.Models.Coordinates(
                                latitude: $0.latitude.rounded(to: 6),
                                longitude: $0.longitude.rounded(to: 6)
                            )
                            transportAssetQuoteRequest.destinationCoordinates =
                                newCoordinates.latitude == 0 && newCoordinates.longitude == 0
                                ? nil : newCoordinates
                            tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                                transportAssetQuoteRequest
                            )
                        }
                    ),
                    symbol: .sunset,
                    title: "Coordinates",
                    placeholder: "Required",
                    markerTitle: "Destination",
                    markerColor: .red
                )
                FormTextRow(
                    value: Binding(
                        get: { transportAssetQuoteRequest.destinationAddress?.value ?? "" },
                        set: {
                            transportAssetQuoteRequest.destinationAddress =
                                $0.isEmpty ? nil : .init(value: $0)
                            tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                                transportAssetQuoteRequest
                            )
                        }
                    ),
                    symbol: .sunset,
                    title: "Address",
                    placeholder: "Automatic",
                )
            }

            FormNumberRow(
                value: Binding(
                    get: { transportAssetQuoteRequest.seats },
                    set: {
                        transportAssetQuoteRequest.seats = $0
                        tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                            transportAssetQuoteRequest
                        )
                    }
                ),
                symbol: .figureSeatedSeatbelt,
                title: "Seats",
                placeholder: "Automatic",
                format: .number,
            )

            // FIXME: Show drop-down menu of known assets
            FormTextRow(
                value: Binding(
                    get: { transportAssetQuoteRequest.serviceAssetID ?? "" },
                    set: {
                        transportAssetQuoteRequest.serviceAssetID = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                            transportAssetQuoteRequest
                        )
                    }
                ),
                symbol: .diamond,
                title: "Service Asset ID",
                placeholder: "Automatic",
            )

            FormChoiceRow(
                selectedValueID: Binding(
                    get: { transportAssetQuoteRequest.serviceAccountID },
                    set: {
                        transportAssetQuoteRequest.serviceAccountID = $0
                        tradeAssetQuoteRequest = .TransportAssetQuoteRequest(
                            transportAssetQuoteRequest
                        )
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .TransportAccount(let transportAccount) = $0 else { return nil }
                    return .init(
                        id: transportAccount.serviceAccountID,
                        description: transportAccount.nickname,
                        logo: .url(transportAccount.service.logoURL)
                    )
                },
                symbol: .buildingColumns,
                title: "Service Account",
                placeholder: "Automatic",
            )

        // FIXME: Placeholder text label
        case .OtherAssetQuoteRequest, .NothingAssetQuoteRequest: Spacer()
        }
    }
}
