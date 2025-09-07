import UIKit
import SwiftUI
import SDWebImage
import CleverTapSDK
import CTTemplates

class CoachmarkScreenViewController: UIViewController, CleverTapDisplayUnitDelegate {
    
    @IBOutlet weak var bottomCard: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet var categoriesCardViews: [UIView]!
    @IBOutlet var recomendedCardViews: [UIView]!
    @IBOutlet var categoriesImageViews: [UIImageView]!
    @IBOutlet var recomendedImageViews: [UIImageView]!
    @IBOutlet weak var searchBar: UISearchBar!
    private var cartIcon: UIImageView!
    private var helpIcon: UIImageView!
    private var settingsIcon: UIImageView!
    
    private let stackView = UIStackView()
    
    var coachmarkTargets: [String: UIView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(3)
        
        setupBottomBar()
        setupProfileAndBannerImages()
        setupCardViews()
        
        coachmarkTargets = [
            "profile_image": profileImage,
            "search": searchBar,
            "cart": cartIcon,
            "support_help": helpIcon,
            "settings": settingsIcon
        ]
        
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
        
        //        CleverTap.sharedInstance()?.recordEvent("coachmarks_nd")
        
        CleverTap.sharedInstance()?.recordEvent("CoachmarksND")
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
            CoachmarkManager.shared.showCoachmarks(fromJson: customKV, in: self.view, targets: self.coachmarkTargets){
                CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unit.unitID!)
            }
        } else {
            print("Failed to get JSON data for Display Unit")
        }
        
    }
    
    private func setupBottomBar() {
        let bottomCard = UIView()
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.backgroundColor = UIColor.systemGray6
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let homeIcon = createButton(named: "house.fill", action: #selector(homeClicked))
        cartIcon = createIcon(named: "cart.fill")
        helpIcon = createIcon(named: "questionmark.circle.fill")
        settingsIcon = createIcon(named: "gearshape.fill")
        
        
        homeIcon.accessibilityIdentifier = "home"
        
        [homeIcon, cartIcon, helpIcon, settingsIcon].forEach { stackView.addArrangedSubview($0) }
        
        view.addSubview(bottomCard)
        bottomCard.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomCard.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -30),
            stackView.centerYAnchor.constraint(equalTo: bottomCard.centerYAnchor)
        ])
    }
    
    private func setupProfileAndBannerImages() {
        profileImage.sd_setImage(with: URL(string: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"))
        bannerImage.sd_setImage(with: URL(string: "https://github.com/Karthik-CT/image-gallery/blob/main/Banner/burger_banner.png?raw=true"))
    }
    
    
    private func setupCardViews() {
        let categoryImages = [
            "https://cdn-icons-png.flaticon.com/512/1046/1046784.png",
            "https://cdn-icons-png.flaticon.com/512/1046/1046781.png",
            "https://cdn-icons-png.flaticon.com/512/1046/1046786.png",
            "https://cdn-icons-png.flaticon.com/512/1046/1046785.png"
        ]
        
        let recommendedImages = [
            "https://cdn-icons-png.flaticon.com/512/1046/1046771.png",
            "https://cdn-icons-png.flaticon.com/512/1046/1046784.png",
            "https://cdn-icons-png.flaticon.com/512/1046/1046786.png",
            "https://cdn-icons-png.flaticon.com/512/1046/1046789.png"
        ]
        
        for (index, cardView) in categoriesCardViews.enumerated() {
            setupCard(cardView, imageView: categoriesImageViews[index], imageUrl: categoryImages[index])
        }
        
        for (index, recCardView) in recomendedCardViews.enumerated() {
            setupCard(recCardView, imageView: recomendedImageViews[index], imageUrl: recommendedImages[index])
        }
    }
    
    private func setupCard(_ cardView: UIView, imageView: UIImageView, imageUrl: String) {
        cardView.applyCardStyle()
        imageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    @objc func homeClicked() {
        print("Home icon clicked")
    }
    
    private func createButton(named: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let icon = UIImage(systemName: named)?.withRenderingMode(.alwaysTemplate)
        button.setImage(icon, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: action, for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        return button
    }
    
    private func createIcon(named: String) -> UIImageView {
        let icon = UIImageView(image: UIImage(systemName: named))
        icon.tintColor = .black
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 30),
            icon.heightAnchor.constraint(equalToConstant: 30)
        ])
        return icon
    }
}

extension UIView {
    func applyCardStyle(cornerRadius: CGFloat = 15, shadowColor: UIColor = .black, shadowOpacity: Float = 0.3, shadowOffset: CGSize = CGSize(width: 0, height: 5), shadowRadius: CGFloat = 10) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
}
