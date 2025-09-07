//
//  ViewController.swift
//  push
//
//  Created by Karthik Iyer on 13/12/22.
//

import UIKit
import CleverTapSDK

class ViewController: UIViewController, UNUserNotificationCenterDelegate, CleverTapDisplayUnitDelegate {
    
    @IBOutlet weak var coachmarkbtn: UIButton!
    
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(3)
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
    }
    
    @IBAction func goToCoachmarkScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let coachmarkVC = storyboard.instantiateViewController(withIdentifier: "CoachmarkScreenViewController") as? CoachmarkScreenViewController {
            self.navigationController?.pushViewController(coachmarkVC, animated: true)
        }
    }
    
    @IBAction func goToTooltipsScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tooltipsVC = storyboard.instantiateViewController(withIdentifier: "TooltipsScreenViewController") as? TooltipsScreenViewController {
            self.navigationController?.pushViewController(tooltipsVC, animated: true)
        }
    }
    
    @IBAction func goToSpotlightsScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let spotlightsVC = storyboard.instantiateViewController(withIdentifier: "SpotlightsScreenViewController") as? SpotlightsScreenViewController {
            self.navigationController?.pushViewController(spotlightsVC, animated: true)
        }
    }
    
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
