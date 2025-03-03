//
//  ViewController.swift
//  push
//
//  Created by Karthik Iyer on 13/12/22.
//

import UIKit
import CleverTapSDK

class ViewController: UIViewController, UNUserNotificationCenterDelegate, CleverTapDisplayUnitDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtIdentity: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtBottomEditText: UITextField!
    @IBOutlet weak var bottomCard: UIView!
    @IBOutlet weak var iconView: UIStackView!
    @IBOutlet weak var bellIcon: UIButton!
    @IBOutlet weak var trashIcon: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    var coachmarkView: UIView!
    let center  = UNUserNotificationCenter.current()
    var coachmarksData: [(targetView: UIView, title: String, message: String)] = []
    var currentCoachmarkIndex = 0
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(3)
        
        let bottomCard = UIView()
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.backgroundColor = UIColor.systemGray6
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing // This ensures even spacing
        stackView.alignment = .center
        stackView.spacing = 0 // No need for manual spacing when using equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Function to create icons
        func createIcon(named: String) -> UIImageView {
            let icon = UIImageView(image: UIImage(systemName: named))
            icon.tintColor = .blue
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: 30), // Adjust icon size
                icon.heightAnchor.constraint(equalToConstant: 30)
            ])
            return icon
        }

        // Create icons
        let homeIcon = createButton(named: "house.fill", action: #selector(homeClicked))
        let heartIcon = createIcon(named: "heart.fill")
        let cartIcon = createIcon(named: "cart.fill")
        let profileIcon = createIcon(named: "person.fill")
        let settingsIcon = createIcon(named: "gearshape.fill")

        // Add icons to stack view
        [homeIcon, heartIcon, cartIcon, profileIcon,settingsIcon].forEach { stackView.addArrangedSubview($0) }

        view.addSubview(bottomCard)
        bottomCard.addSubview(stackView)

        // Fix bottom bar position
        NSLayoutConstraint.activate([
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor), // Stick to bottom
            bottomCard.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Center stack view within bottom bar
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 30), // Ensure proper spacing
            stackView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -30),
            stackView.centerYAnchor.constraint(equalTo: bottomCard.centerYAnchor)
        ])

        txtName.delegate = self
        txtEmail.delegate = self
        txtIdentity.delegate = self
        txtMobileNumber.delegate = self
        
        txtName.accessibilityIdentifier = "txtName"
        txtEmail.accessibilityIdentifier = "txtEmail"
        txtMobileNumber.accessibilityIdentifier = "txtMobileNumber"
        btnLogin.accessibilityIdentifier = "btnLogin"
        txtBottomEditText.accessibilityIdentifier = "txtBottomEditText"
        homeIcon.accessibilityIdentifier = "homeIcon"
        profileIcon.accessibilityIdentifier = "profileIcon"
        heartIcon.accessibilityIdentifier = "heartIcon"
        settingsIcon.accessibilityIdentifier = "settingsIcon"
        bellIcon.accessibilityIdentifier = "bellIcon"
        trashIcon.accessibilityIdentifier = "trashIcon"
        loginLabel.accessibilityIdentifier = "loginLabel"
        
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
    }
    
    
    @objc func homeClicked() {
        print("Home icon clicked")
    }
    
    func createButton(named: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let icon = UIImage(systemName: named)?.withRenderingMode(.alwaysTemplate)
        button.setImage(icon, for: .normal)
        button.tintColor = .blue
        button.addTarget(self, action: action, for: .touchUpInside) // Attach action
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40), // Adjust button size
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        return button
    }

    func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        for unit in displayUnits {
            prepareDisplayView(unit)
        }
    }
    
    // Define this function to handle the display unit processing
    func prepareDisplayView(_ unit: CleverTapDisplayUnit) {
        if let jsonData = unit.json {
            print("Received Display Unit: \(String(describing: jsonData["custom_kv"]))")
        } else {
            print("Failed to get JSON data for Display Unit")
        }
    }
    
    @IBAction func goToCoachmarkScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let coachmarkVC = storyboard.instantiateViewController(withIdentifier: "CoachmarkScreenViewController") as? CoachmarkScreenViewController {
            // Push the HomeScreenViewController
            self.navigationController?.pushViewController(coachmarkVC, animated: true)
        }
    }
    
    @IBAction func btnClickLogin(_ sender: UIButton) {
        let profile: Dictionary<String, Any> = [
            "Name": txtName.text!,
            "Identity": txtIdentity.text!,
            "Email": txtEmail.text!,
            "Phone": "+91"+txtMobileNumber.text!,
            "MSG-email": true,
            "MSG-push": true,
            "MSG-sms": true,
            "MSG-whatsapp": true
        ]
        CleverTap.sharedInstance()?.onUserLogin(profile)
        
        let defaults = UserDefaults(suiteName: "group.clevertapTest")
        defaults!.set(txtEmail.text!, forKey: "userEmailID")
        defaults!.set(txtIdentity.text!, forKey: "userIdentity")
        defaults!.set(txtMobileNumber.text!, forKey: "userMobileNumber")
        
        self.showToast(message: "Logged In!", font: .systemFont(ofSize: 12.0))
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as? HomeScreenViewController {
            // Push the HomeScreenViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        let profile: Dictionary<String, Any> = [
            "Name": txtName.text!,
            "Identity": txtIdentity.text!,
            "Email": txtEmail.text!,
            "Phone": "+91"+txtMobileNumber.text!,
            "MSG-email": true,
            "MSG-push": true,
            "MSG-sms": true,
            "MSG-whatsapp": true
        ]
        CleverTap.sharedInstance()?.onUserLogin(profile)
        
        let defaults = UserDefaults(suiteName: "group.clevertapTest")
        defaults!.set(txtEmail.text!, forKey: "userEmailID")
        defaults!.set(txtIdentity.text!, forKey: "userIdentity")
        defaults!.set(txtMobileNumber.text!, forKey: "userMobileNumber")
        
        self.showToast(message: "Logged In!", font: .systemFont(ofSize: 12.0))
        
        let namestoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = namestoryboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func pushProfileBtn(_ sender: UIButton) {
        let profile: Dictionary<String, Any> = [
            "Name": txtName.text!,
            "Identity": txtIdentity.text!,
            "Email": txtEmail.text!,
            "Phone": txtMobileNumber.text!,
            "MSG-email": true,
            "MSG-push": true,
            "MSG-sms": true,
            "MSG-whatsapp": true
        ]
        CleverTap.sharedInstance()?.profilePush(profile)
        
        self.showToast(message: "Push Profile Clicked!", font: .systemFont(ofSize: 12.0))
        
        let namestoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = namestoryboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
