//
//  ViewController.swift
//  push
//
//  Created by Karthik Iyer on 13/12/22.
//

import UIKit
import CleverTapSDK

class ViewController: UIViewController, UNUserNotificationCenterDelegate, CleverTapDisplayUnitDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(3)
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
    }
    
    
    @objc func homeClicked() {
        print("Home icon clicked")
    }
    
    @IBAction func goToCoachmarkScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let coachmarkVC = storyboard.instantiateViewController(withIdentifier: "CoachmarkScreenViewController") as? CoachmarkScreenViewController {
            // Push the HomeScreenViewController
            self.navigationController?.pushViewController(coachmarkVC, animated: true)
        }
    }
    
    @IBAction func goToTooltipsScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tooltipsVC = storyboard.instantiateViewController(withIdentifier: "TooltipsScreenViewController") as? TooltipsScreenViewController {
            self.navigationController?.pushViewController(tooltipsVC, animated: true)
        }
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
