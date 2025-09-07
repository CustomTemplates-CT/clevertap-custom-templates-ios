import UIKit

@MainActor
public class TooltipManager {
    
    public  let shared = TooltipManager()
    
    var tooltipsData: [[String: Any]] = []
    var currentTooltipIndex: Int = 0
    var parentView: UIView?
    var targets: [String: UIView] = [:]
    
    init() {}
    
    /// Show tooltips from JSON
    public func showTooltips(fromJson json: Any, in parentView: UIView, targets: [String: UIView], onComplete: @escaping () -> Void) {
        self.parentView = parentView
        self.currentTooltipIndex = 0
        self.targets = targets
        
        var jsonDict: [String: Any] = [:]
        
        if let arrayJson = json as? [[String: Any]], let firstItem = arrayJson.first {
            jsonDict = firstItem
        } else if let dictJson = json as? [String: Any] {
            jsonDict = dictJson
        } else {
            return
        }
        
        if let ndJsonString = jsonDict["nd_json"] as? String,
           let ndJsonData = ndJsonString.data(using: .utf8),
           let parsedNdJson = try? JSONSerialization.jsonObject(with: ndJsonData) as? [String: Any] {
            jsonDict = parsedNdJson
        } else if let ndJsonDict = jsonDict["nd_json"] as? [String: Any] {
            jsonDict = ndJsonDict
        }
        
        let tooltipCount: Int
        if let count = jsonDict["nd_tooltips_count"] as? Int {
            tooltipCount = count
        } else if let countString = jsonDict["nd_tooltips_count"] as? String, let countInt = Int(countString) {
            tooltipCount = countInt
        } else {
            return
        }
        
        var steps: [[String: Any]] = []
        for index in 1...tooltipCount {
            let idKey = "nd_view\(index)_id"
            let messageKey = "nd_view\(index)_tooltip"
            let gravityKey = "nd_view\(index)_tooltip_gravity"
            let colorKey = "nd_background_color"
            let textColorKey = "nd_text_color"
            
            if let targetId = jsonDict[idKey] as? String,
               let message = jsonDict[messageKey] as? String
            {
                let gravityString = (jsonDict[gravityKey] as? String ?? "right").lowercased()
                let gravity: TooltipGravity
                switch gravityString {
                case "top": gravity = .top
                case "bottom": gravity = .bottom
                case "left": gravity = .left
                default: gravity = .right
                }
                
                let bgColorHex = (jsonDict[colorKey] as? String) ?? "#FF0000" // fallback red
                let bubbleColor = UIColor(hex: bgColorHex) ?? .systemRed
                
                let textColorHex = (jsonDict[textColorKey] as? String) ?? "#FFFFFF"
                let textColor = UIColor(hex: textColorHex) ?? .white
                
                steps.append([
                    "targetViewId": targetId,
                    "message": message,
                    "gravity": gravity,
                    "bubbleColor": bubbleColor,
                    "textColor": textColor
                ])
            } else {
                print("Skipping tooltip \(index): Missing id/message in JSON")
            }
        }
        
        self.tooltipsData = steps
        
        showNextTooltip(onComplete: onComplete)
    }
    
    func showNextTooltip(onComplete: @escaping () -> Void) {
        guard currentTooltipIndex < tooltipsData.count, let parentView = self.parentView else {
            onComplete()
            return
        }
        
        let step = tooltipsData[currentTooltipIndex]
        if let targetId = step["targetViewId"] as? String,
           let targetView = findViewByIdentifier(targetId, in: parentView) {
            
            let message = step["message"] as? String ?? ""
            let gravity = step["gravity"] as? TooltipGravity ?? .right
            let bubbleColor = step["bubbleColor"] as? UIColor ?? .systemRed
            let textColor = step["textColor"] as? UIColor ?? .white
            
            TooltipView.show(message: message, for: targetView, in: parentView, gravity: gravity, bubbleColor: bubbleColor, bubbleTextColor: textColor) {
                self.currentTooltipIndex += 1
                self.showNextTooltip(onComplete: onComplete)
            }
        } else {
            currentTooltipIndex += 1
            showNextTooltip(onComplete: onComplete)
        }
    }
    
    func findViewByIdentifier(_ identifier: String, in view: UIView) -> UIView? {
        return targets[identifier]
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
