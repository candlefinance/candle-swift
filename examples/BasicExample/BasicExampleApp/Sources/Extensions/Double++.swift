import Foundation

extension Double {
    func rounded(to decimalPlaces: Int) -> Self {
        let power = pow(10.0, Double(decimalPlaces))
        return (self * power).rounded() / power
    }
}
