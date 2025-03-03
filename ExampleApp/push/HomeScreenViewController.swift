//
//  HomeScreenViewController.swift
//  push
//
//  Created by Karthik Iyer on 25/02/23.
//

import UIKit
import CleverTapSDK

class HomeScreenViewController: UIViewController, CleverTapInboxViewControllerDelegate, CleverTapDisplayUnitDelegate {

    @IBOutlet weak var txtPushEvent: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(3)
        
        if let txtPushEvent = txtPushEvent {
            txtPushEvent.delegate = self
        } else {
            print("txtPushEvent is nil")
        }
        
        //Initialize App Inbox
        CleverTap.sharedInstance()?.initializeInbox(callback: ({ (success) in
            let messageCount = CleverTap.sharedInstance()?.getInboxMessageCount()
            let unreadCount = CleverTap.sharedInstance()?.getInboxMessageUnreadCount()
            print("Inbox Message:\(String(describing: messageCount))/\(String(describing: unreadCount)) unread")
         }))
        
        //Intialize Native Display
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
        
    }
    
    @IBAction func PushEventButton(_ sender: UIButton) {
        CleverTap.sharedInstance()?.recordEvent(txtPushEvent.text!)
        self.showToast(message: "Event Pushed!", font: .systemFont(ofSize: 12.0))
    }
    
    @IBAction func AppInboxButton(_ sender: Any) {
        CleverTap.sharedInstance()?.recordEvent("App Inbox Event")
        self.showToast(message: "Event Pushed!", font: .systemFont(ofSize: 12.0))
        showAppInbox()
    }
    
    func showAppInbox() {
        let style = CleverTapInboxStyleConfig.init()
        style.title = "App Inbox"
        style.navigationTintColor = .black
        if let inboxController = CleverTap.sharedInstance()?.newInboxViewController(with: style, andDelegate: self) {
            let navigationController = UINavigationController.init(rootViewController: inboxController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        let units:[CleverTapDisplayUnit] = displayUnits
        for i in 0..<(units.count) {
            let unit = units[i]
            print("ND Unit:", unit)
            prepareDisplayView(unit)
        }
    }
    
    func prepareDisplayView(_ unit: CleverTapDisplayUnit) {
        print("ND Title:", unit.contents![0].title!)
        for item in unit.contents! {
            lblTitle.text =  "Title: "+item.title!
            lblMessage.text =  "Message: "+item.message!
        }
        
        CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unit.unitID!)
        CleverTap.sharedInstance()?.recordDisplayUnitViewedEvent(forID: unit.unitID!)
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

extension HomeScreenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
