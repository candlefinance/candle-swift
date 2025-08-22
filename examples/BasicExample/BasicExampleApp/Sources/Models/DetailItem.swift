import Foundation

struct Detail {
    let label: String
    let value: String
    let iconName: String  // FIXME: Make this type-safe

    init(label: String, value: String, iconName: String) {
        self.label = label
        self.value = value
        self.iconName = iconName
    }
}

// FIXME: Model [Detail] as [String: Omit<Detail, 'label'>] so that the compiler guarantees this is a unique ID
extension Detail: Identifiable { var id: String { label } }
