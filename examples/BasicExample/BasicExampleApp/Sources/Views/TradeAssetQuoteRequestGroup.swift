import Candle
import Foundation
import MapKit
import SwiftUI

struct TradeAssetQuoteRequestGroup: View {

    @Binding var tradeAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest
    let assetAccounts: [Candle.Models.AssetAccount]

    var body: some View {
        switch tradeAssetQuoteRequest {
        case .fiat(var fiatAssetQuoteRequest):
            // FIXME: Add drop-down menu for currency and format amount using it
            FormChoiceRow(
                selectedValueID: Binding(
                    get: { fiatAssetQuoteRequest.currencyCode },
                    set: {
                        fiatAssetQuoteRequest.currencyCode = $0
                        tradeAssetQuoteRequest = .fiat(fiatAssetQuoteRequest)
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
                        tradeAssetQuoteRequest = .fiat(fiatAssetQuoteRequest)
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
                        tradeAssetQuoteRequest = .fiat(fiatAssetQuoteRequest)
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .fiat(let fiatAccount) = $0 else { return nil }
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

        case .crypto(var cryptoAssetQuoteRequest):
            // FIXME: Show color + logoURL
            FormTextRow(
                value: Binding(
                    get: { cryptoAssetQuoteRequest.symbol ?? "" },
                    set: {
                        cryptoAssetQuoteRequest.symbol = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .crypto(cryptoAssetQuoteRequest)
                    }
                ),
                symbol: .chartLineUptrendXyaxis,
                title: "Symbol",
                placeholder: "Required",
            )
            FormNumberRow(
                value: Binding(
                    get: { cryptoAssetQuoteRequest.amount },
                    set: {
                        cryptoAssetQuoteRequest.amount = $0
                        tradeAssetQuoteRequest = .crypto(cryptoAssetQuoteRequest)
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
                    get: { cryptoAssetQuoteRequest.serviceAssetID ?? "" },
                    set: {
                        cryptoAssetQuoteRequest.serviceAssetID = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .crypto(cryptoAssetQuoteRequest)
                    }
                ),
                symbol: .diamond,
                title: "Service Asset ID",
                placeholder: "Automatic",
            )

            FormChoiceRow(
                selectedValueID: Binding(
                    get: { cryptoAssetQuoteRequest.serviceAccountID },
                    set: {
                        cryptoAssetQuoteRequest.serviceAccountID = $0
                        tradeAssetQuoteRequest = .crypto(cryptoAssetQuoteRequest)
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .crypto(let cryptoAccount) = $0 else { return nil }
                    return .init(
                        id: cryptoAccount.serviceAccountID,
                        description: cryptoAccount.nickname,
                        logo: .url(cryptoAccount.service.logoURL)
                    )
                },
                symbol: .buildingColumns,
                title: "Service Account",
                placeholder: "Automatic",
            )

        case .stock(var stockAssetQuoteRequest):
            // FIXME: Show color + logoURL
            FormTextRow(
                value: Binding(
                    get: { stockAssetQuoteRequest.symbol ?? "" },
                    set: {
                        stockAssetQuoteRequest.symbol = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .stock(stockAssetQuoteRequest)
                    }
                ),
                symbol: .chartLineUptrendXyaxis,
                title: "Symbol",
                placeholder: "Required",
            )
            FormNumberRow(
                value: Binding(
                    get: { stockAssetQuoteRequest.amount },
                    set: {
                        stockAssetQuoteRequest.amount = $0
                        tradeAssetQuoteRequest = .stock(stockAssetQuoteRequest)
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
                    get: { stockAssetQuoteRequest.serviceAssetID ?? "" },
                    set: {
                        stockAssetQuoteRequest.serviceAssetID = $0.isEmpty ? nil : $0
                        tradeAssetQuoteRequest = .stock(stockAssetQuoteRequest)
                    }
                ),
                symbol: .diamond,
                title: "Service Asset ID",
                placeholder: "Automatic",
            )
            FormChoiceRow(
                selectedValueID: Binding(
                    get: { stockAssetQuoteRequest.serviceAccountID },
                    set: {
                        stockAssetQuoteRequest.serviceAccountID = $0
                        tradeAssetQuoteRequest = .stock(stockAssetQuoteRequest)
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .stock(let stockAccount) = $0 else { return nil }
                    return .init(
                        id: stockAccount.serviceAccountID,
                        description: stockAccount.nickname,
                        logo: .url(stockAccount.service.logoURL)
                    )
                },
                symbol: .buildingColumns,
                title: "Service Account",
                placeholder: "Automatic",
            )

        case .transport(var transportAssetQuoteRequest):
            // FIXME: Show color + logoURL
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
                            tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
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
                            tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
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
                            tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
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
                            tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
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
                        tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
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
                        tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
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
                        tradeAssetQuoteRequest = .transport(transportAssetQuoteRequest)
                    }
                ),
                allowedValues: assetAccounts.compactMap {
                    guard case .transport(let transportAccount) = $0 else { return nil }
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
        case .other, .nothing: Spacer()
        }
    }
}
