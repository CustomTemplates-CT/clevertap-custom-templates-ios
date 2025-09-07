import UIKit
import CleverTapSDK

class TooltipsScreenViewController: UIViewController, CleverTapDisplayUnitDelegate {
    
    @IBOutlet weak var TextView1: UILabel!
    @IBOutlet weak var TextView2: UILabel!
    @IBOutlet weak var TextView3: UILabel!
    @IBOutlet weak var TextView4: UILabel!
    
    lazy var tooltipTargets: [String: UIView] = [
        "TextView1": TextView1,
        "TextView2": TextView2,
        "TextView3": TextView3,
        "TextView4": TextView4
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CleverTap.setDebugLevel(3)
        
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
        
        CleverTap.sharedInstance()?.recordEvent("tooltips_nd")
        
    }
    
    func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        for unit in displayUnits {
            prepareDisplayView(unit)
        }
    }
    
    func prepareDisplayView(_ unit: CleverTapDisplayUnit) {
        if let jsonData = unit.json,
           let customKV = jsonData["custom_kv"] as? [String: Any] {
            print("Native Display Data: \(customKV)")
            CleverTap.sharedInstance()?.recordDisplayUnitViewedEvent(forID: unit.unitID!)
            TooltipManager.shared.showTooltips(fromJson: customKV, in: self.view, targets: self.tooltipTargets){
                CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unit.unitID!)
            }
        } else {
            print("Failed to get JSON data for Display Unit")
        }
    }
}
