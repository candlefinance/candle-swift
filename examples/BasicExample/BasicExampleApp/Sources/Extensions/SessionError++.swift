import Candle

// FIXME: Separate title and subtitle
extension Models.SessionError {
    var formatted: (title: String, message: String) {
        switch self {
        case .createUserError(let createUserError):
            switch createUserError {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_app:
                    return (title: "Create User Error: App Not Found", message: payload.message)
                }
            case .unprocessableContent(let payload):
                switch payload.kind {
                case .schemaInvalid_request:
                    return (
                        title: "Create User Error: Request Schema Invalid", message: payload.message
                    )
                }
            case .unauthorized(let payload):
                switch payload.kind {
                case .badAuthorization_app:
                    return (
                        title: "Create User Error: Bad App Authorization", message: payload.message
                    )
                }
            case .forbidden(let payload):
                switch payload.kind {
                case .disabledPendingPayment_app:
                    return (
                        title: "Create User Error: App Disabled Pending Payment",
                        message: payload.message
                    )
                }
            case .tooManyRequests(let payload):
                switch payload.kind {
                case .overUserLimit_app:
                    return (
                        title: "Create User Error: App Over User Limit", message: payload.message
                    )
                }
            case .internalServerError(let payload):
                switch payload.kind {
                case .unexpected:
                    return (
                        title: "Create User Error: Internal Server Error", message: payload.message
                    )
                }
            case .unexpectedStatusCode(let statusCode):
                return (
                    title: "Create User Error: Unexpected Status Code",
                    message: "Received \(statusCode) response"
                )
            case .networkError(let errorDescription):
                return (title: "Create User Error: Network Error", message: errorDescription)
            }
        case .updateUserError(let updateUserError):
            switch updateUserError {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    return (title: "Update User Error: User Not Found", message: payload.message)
                case .notFound_app:
                    return (title: "Update User Error: App Not Found", message: payload.message)
                }
            case .unprocessableContent(let payload):
                switch payload.kind {
                case .schemaInvalid_request:
                    return (
                        title: "Update User Error: Request Schema Invalid", message: payload.message
                    )
                }
            case .unauthorized(let payload):
                switch payload.kind {
                case .badAuthorization_user:
                    return (
                        title: "Update User Error: Bad User Authorization", message: payload.message
                    )
                case .badAuthorization_app:
                    return (
                        title: "Update User Error: Bad App Authorization", message: payload.message
                    )
                }
            case .forbidden(let payload):
                switch payload.kind {
                case .disabledPendingPayment_app:
                    return (
                        title: "Update User Error: App Disabled Pending Payment",
                        message: payload.message
                    )
                }
            case .conflict(let payload):
                switch payload.kind {
                case .different_app:
                    return (title: "Update User Error: Different App", message: payload.message)
                case .different_appUser:
                    return (
                        title: "Update User Error: Different App User", message: payload.message
                    )
                }
            case .internalServerError(let payload):
                switch payload.kind {
                case .unexpected:
                    return (
                        title: "Update User Error: Internal Server Error", message: payload.message
                    )
                }
            case .unexpectedStatusCode(let statusCode):
                return (
                    title: "Update User Error: Unexpected Status Code",
                    message: "Received \(statusCode) response"
                )
            case .networkError(let errorDescription):
                return (title: "Update User Error: Network Error", message: errorDescription)
            }
        case .openSessionError:
            return (title: "Open Session Error", message: "Check your VPN/proxy configuration")
        case .keychainError:
            return (title: "Keychain Error", message: "Check your access group entitlements")
        }
    }
}
