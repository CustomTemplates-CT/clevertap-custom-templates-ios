//
//  SpotlightsScreenViewController.swift
//  push
//
//  Created by Karthik Iyer on 07/09/25.
//

import UIKit
import CleverTapSDK
import CTTemplates

class SpotlightsScreenViewController: UIViewController, CleverTapDisplayUnitDelegate {
    
    @IBOutlet weak var TextView1: UILabel!
    @IBOutlet weak var TextView2: UILabel!
    @IBOutlet weak var TextView3: UILabel!
    
    lazy var spotlightTargets: [String: UIView] = [
        "TextView1": TextView1,
        "TextView2": TextView2,
        "TextView3": TextView3
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CleverTap.setDebugLevel(3)
        
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
        
//        CleverTap.sharedInstance()?.recordEvent("spotlights_nd")
        CleverTap.sharedInstance()?.recordEvent("SpotlightsND")
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
            SpotlightManager.shared.showSpotlights(fromJson: customKV, in: self.view, targets: self.spotlightTargets){
                CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unit.unitID!)
            }
        } else {
            print("Failed to get JSON data for Display Unit")
        }
    }
}

