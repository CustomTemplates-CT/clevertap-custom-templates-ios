import UIKit

@MainActor
public class SpotlightManager {
    
    public static let shared = SpotlightManager()
    
    var spotlightData: [[String: Any]] = []
    var currentSpotlightIndex: Int = 0
    var parentView: UIView?
    var targets: [String: UIView] = [:]
    var textColor: UIColor = .white
    var spotlightShape: SpotlightShape = .circle
    
    private init() {}
    
    public func showSpotlights(
        fromJson json: Any,
        in parentView: UIView,
        targets: [String: UIView],
        onComplete: @escaping () -> Void
    ) {
        self.parentView = parentView
        self.targets = targets
        self.currentSpotlightIndex = 0
        
        var jsonDict: [String: Any] = [:]
        
        // Handle array or dict
        if let arrayJson = json as? [[String: Any]], let firstItem = arrayJson.first {
            jsonDict = firstItem
        } else if let dictJson = json as? [String: Any] {
            jsonDict = dictJson
        } else {
            return
        }
        
        // Handle nested nd_json string or dict
        if let ndJsonString = jsonDict["nd_json"] as? String,
           let ndJsonData = ndJsonString.data(using: .utf8),
           let parsedNdJson = try? JSONSerialization.jsonObject(with: ndJsonData) as? [String: Any] {
            jsonDict = parsedNdJson
        } else if let ndJsonDict = jsonDict["nd_json"] as? [String: Any] {
            jsonDict = ndJsonDict
        }
        
        // Count of spotlights
        let spotlightCount: Int
        if let count = jsonDict["nd_spotlight_count"] as? Int {
            spotlightCount = count
        } else if let countString = jsonDict["nd_spotlight_count"] as? String,
                  let countInt = Int(countString) {
            spotlightCount = countInt
        } else {
            return
        }
        
        // Extract text color
        if let colorHex = jsonDict["nd_text_color"] as? String {
            self.textColor = UIColor(hex: colorHex) ?? .white
        }
        
        // Extract shape
        if let shapeString = jsonDict["nd_spotlight_shape"] as? String {
            switch shapeString.lowercased() {
            case "rectangle":
                self.spotlightShape = .rectangle
            case "roundedrectangle":
                self.spotlightShape = .roundedRect(cornerRadius: 8)
            default:
                self.spotlightShape = .circle
            }
        }
        
        // Build spotlight steps
        var steps: [[String: Any]] = []
        for index in 1...spotlightCount {
            let idKey = "nd_view\(index)_id"
            let titleKey = "nd_view\(index)_title"
            let subtitleKey = "nd_view\(index)_subtitle"
            
            if let targetId = jsonDict[idKey] as? String,
               let title = jsonDict[titleKey] as? String,
               let subtitle = jsonDict[subtitleKey] as? String {
                steps.append([
                    "targetViewId": targetId,
                    "title": title,
                    "subtitle": subtitle
                ])
            }
        }
        
        self.spotlightData = steps
        showNextSpotlight(onComplete: onComplete)
    }
    
    func showNextSpotlight(onComplete: @escaping () -> Void) {
        guard currentSpotlightIndex < spotlightData.count,
              let parentView = self.parentView else {
            onComplete()
            return
        }
        
        let step = spotlightData[currentSpotlightIndex]
        if let targetId = step["targetViewId"] as? String,
           let targetView = targets[targetId] {
            
            let title = step["title"] as? String ?? ""
            let subtitle = step["subtitle"] as? String ?? ""
            
            let spotlightStep = SpotlightStep(
                targetView: targetView,
                title: title,
                subtitle: subtitle,
                shape: spotlightShape
            )
            
            let spotlightView = SpotlightView(step: spotlightStep)
            spotlightView.titleLabel.textColor = textColor
            spotlightView.subtitleLabel.textColor = textColor
            
            spotlightView.onDismiss = { [weak self, weak spotlightView] in
                spotlightView?.removeFromSuperview()
                self?.currentSpotlightIndex += 1
                self?.showNextSpotlight(onComplete: onComplete)
            }
            
            parentView.addSubview(spotlightView)
        } else {
            currentSpotlightIndex += 1
            showNextSpotlight(onComplete: onComplete)
        }
    }
}
