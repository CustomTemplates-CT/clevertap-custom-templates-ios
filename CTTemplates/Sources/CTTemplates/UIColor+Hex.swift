import UIKit

extension UIColor {
    convenience init?(ct_hex: String) {
        var formatted = ct_hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if formatted.hasPrefix("#") { formatted.removeFirst() }
        
        var rgb: UInt64 = 0
        guard Scanner(string: formatted).scanHexInt64(&rgb) else { return nil }
        
        switch formatted.count {
        case 6:
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        default:
            return nil
        }
    }
}
