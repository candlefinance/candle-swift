import Candle

struct TradeAssetViewModel {
    let tradeAsset: Models.TradeAsset

    var details: [Detail] {
        switch tradeAsset {
        case .FiatAsset(let fiatAsset):
            return [
                Detail(
                    label: "Asset Kind",
                    value: fiatAsset.assetKind.rawValue,
                    iconName: "arrow.up.arrow.down.circle"
                ),
                Detail(
                    label: "Linked Account ID",
                    value: fiatAsset.linkedAccountID,
                    iconName: "number"
                ),
                Detail(
                    label: "Service",
                    value: fiatAsset.service.rawValue,
                    iconName: "number"
                ),
                Detail(
                    label: "Service Account ID",
                    value: fiatAsset.serviceAccountID,
                    iconName: "number"
                ),
                fiatAsset.serviceTradeID.map {
                    Detail(
                        label: "Service Trade ID",
                        value: $0,
                        iconName: "number"
                    )
                },
                Detail(
                    label: "Amount",
                    value: fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode)),
                    iconName: "dollarsign.circle"
                ),
            ].compactMap { $0 }
        case .MarketTradeAsset(let marketTradeAsset):
            return [
                Detail(
                    label: "Asset Kind",
                    value: marketTradeAsset.assetKind.rawValue,
                    iconName: "arrow.up.arrow.down.circle"
                ),
                Detail(
                    label: "Linked Account ID",
                    value: marketTradeAsset.linkedAccountID,
                    iconName: "number"
                ),
                Detail(
                    label: "Service",
                    value: marketTradeAsset.service.rawValue,
                    iconName: "number"
                ),
                Detail(
                    label: "Service Account ID",
                    value: marketTradeAsset.serviceAccountID,
                    iconName: "number"
                ),
                Detail(
                    label: "Service Trade ID",
                    value: marketTradeAsset.serviceTradeID,
                    iconName: "number"
                ),
                Detail(
                    label: "Serivce Asset ID",
                    value: marketTradeAsset.serviceAssetID,
                    iconName: "number"
                ),
                Detail(
                    label: "Symbol",
                    value: marketTradeAsset.symbol,
                    iconName: "number"
                ),
                Detail(
                    label: "Amount",
                    value: marketTradeAsset.amount.formatted(),
                    iconName: "number"
                ),
                Detail(
                    label: "Color",
                    value: marketTradeAsset.color,
                    iconName: "number"
                ),
                Detail(
                    label: "Name",
                    value: marketTradeAsset.name,
                    iconName: "number"
                ),
                Detail(
                    label: "Logo URL",
                    value: marketTradeAsset.logoURL,
                    iconName: "number"
                ),
            ]
        case .TransportAsset(let transportAsset):
            return [
                Detail(
                    label: "Asset Kind",
                    value: transportAsset.assetKind.rawValue,
                    iconName: "arrow.up.arrow.down.circle"
                ),
                Detail(
                    label: "Linked Account ID",
                    value: transportAsset.linkedAccountID,
                    iconName: "number"
                ),
                Detail(
                    label: "Name",
                    value: transportAsset.name,
                    iconName: "number"
                ),
                Detail(
                    label: "Description",
                    value: transportAsset.description,
                    iconName: "number"
                ),
                Detail(
                    label: "Seats",
                    value: transportAsset.seats.formatted(),
                    iconName: "number"
                ),
                Detail(
                    label: "Image URL",
                    value: transportAsset.imageURL,
                    iconName: "number"
                ),
                Detail(
                    label: "Service Asset ID",
                    value: transportAsset.serviceAssetID,
                    iconName: "number"
                ),
                Detail(
                    label: "Service Trade ID",
                    value: transportAsset.serviceTradeID,
                    iconName: "number"
                ),
                Detail(
                    label: "Origin Address",
                    value: transportAsset.originAddress.value,
                    iconName: "number"
                ),
                Detail(
                    label: "Origin Coordinates: Latitude",
                    value: transportAsset.originCoordinates.latitude.formatted(),
                    iconName: "number"
                ),
                Detail(
                    label: "Origin Coordinates: Longitude",
                    value: transportAsset.originCoordinates.longitude.formatted(),
                    iconName: "number"
                ),
                Detail(
                    label: "Destination Address",
                    value: transportAsset.destinationAddress.value,
                    iconName: "number"
                ),
                Detail(
                    label: "Destination Coordinates: Latitude",
                    value: transportAsset.destinationCoordinates.latitude.formatted(),
                    iconName: "number"
                ),
                Detail(
                    label: "Destination Coordinates: Longitude",
                    value: transportAsset.destinationCoordinates.longitude.formatted(),
                    iconName: "number"
                ),
                Detail(
                    label: "Departure Date Time",
                    value: transportAsset.departureDateTime,
                    iconName: "number"
                ),
                Detail(
                    label: "Arrival Date Time",
                    value: transportAsset.arrivalDateTime,
                    iconName: "number"
                ),
            ]
        case .NothingAsset(let nothingAsset):
            return [
                Detail(
                    label: "Asset Kind",
                    value: nothingAsset.assetKind.rawValue,
                    iconName: "arrow.up.arrow.down.circle"
                )
            ]
        case .OtherAsset(let otherAsset):
            return [
                Detail(
                    label: "Asset Kind",
                    value: otherAsset.assetKind.rawValue,
                    iconName: "arrow.up.arrow.down.circle"
                )
            ]
        }
    }
}
