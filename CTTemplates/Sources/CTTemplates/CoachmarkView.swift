import UIKit

class CoachmarkView: UIView {
    
    var targetView: UIView
    var title: String
    var message: String
    var currentIndex: Int
    var totalSteps: Int
    var onNext: (() -> Void)?
    var onSkip: (() -> Void)?
    var positiveButtonText: String
    var skipButtonText: String
    var positiveButtonBackgroundColor: String
    var skipButtonBackgroundColor: String
    var positiveButtonTextColor: String
    var skipButtonTextColor: String
    var finalButtonText: String
    
    private let stepIndicatorLabel = UILabel()
    private let imageView = UIImageView()
    
    init(targetView: UIView, title: String, message: String, currentIndex: Int, totalSteps: Int, frame: CGRect, positiveButtonText: String, skipButtonText: String, positiveButtonBackgroundColor: String,skipButtonBackgroundColor: String, positiveButtonTextColor: String, skipButtonTextColor: String, finalButtonText: String) {
        self.targetView = targetView
        self.title = title
        self.message = message
        self.currentIndex = currentIndex
        self.totalSteps = totalSteps
        self.positiveButtonText = positiveButtonText
        self.skipButtonText = skipButtonText
        self.positiveButtonBackgroundColor = positiveButtonBackgroundColor
        self.skipButtonBackgroundColor = skipButtonBackgroundColor
        self.positiveButtonTextColor = positiveButtonTextColor
        self.skipButtonTextColor = skipButtonTextColor
        self.finalButtonText = finalButtonText
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Updated Tooltip Positioning
    private func createTooltipView(atY yPosition: CGFloat) -> UIView {
        let tooltipView = UIView(frame: CGRect(x: 20, y: yPosition, width: self.frame.width - 40, height: 145))
        tooltipView.backgroundColor = .white
        tooltipView.layer.cornerRadius = 12
        tooltipView.layer.shadowColor = UIColor.black.cgColor
        tooltipView.layer.shadowOpacity = 0.2
        tooltipView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tooltipView.layer.shadowRadius = 4
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 12, width: tooltipView.frame.width - 32, height: 22))
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        tooltipView.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 16, y: 38, width: tooltipView.frame.width - 32, height: 40))
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0
        tooltipView.addSubview(messageLabel)
        
        let buttonsContainer = UIStackView(frame: CGRect(x: 16, y: 95, width: tooltipView.frame.width - 32, height: 35))
        buttonsContainer.axis = .horizontal
        buttonsContainer.alignment = .fill
        buttonsContainer.distribution = .fillEqually
        buttonsContainer.spacing = 10
        
        let skipButton = UIButton(type: .system)
        var skipConfig = UIButton.Configuration.filled()
        skipConfig.baseBackgroundColor = UIColor(hex: skipButtonBackgroundColor)?.withAlphaComponent(0.3)
        skipConfig.baseForegroundColor = UIColor(hex: skipButtonTextColor)
        skipConfig.cornerStyle = .medium
        skipConfig.title = skipButtonText
        skipButton.configuration = skipConfig
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        skipButton.layer.borderColor = UIColor.black.cgColor // Change color as needed
        skipButton.layer.borderWidth = 1.5
        skipButton.layer.cornerRadius = 8
        skipButton.layer.shadowColor = UIColor.black.cgColor
        skipButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        skipButton.layer.shadowRadius = 4
        skipButton.layer.shadowOpacity = 0.3
        skipButton.layer.masksToBounds = false
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle(currentIndex == totalSteps ? finalButtonText : positiveButtonText, for: .normal)
        nextButton.setTitleColor(UIColor(hex: positiveButtonTextColor), for: .normal)
        nextButton.backgroundColor = UIColor(hex: positiveButtonBackgroundColor)
        nextButton.layer.cornerRadius = 5
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.layer.borderColor = UIColor.red.cgColor // Change color as needed
        nextButton.layer.borderWidth = 1.5
        nextButton.layer.cornerRadius = 8
        nextButton.layer.shadowColor = UIColor.red.cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        nextButton.layer.shadowRadius = 4
        nextButton.layer.shadowOpacity = 0.3
        nextButton.layer.masksToBounds = false
        
        buttonsContainer.addArrangedSubview(skipButton)
        buttonsContainer.addArrangedSubview(nextButton)
        tooltipView.addSubview(buttonsContainer)
        
        if currentIndex == totalSteps {
            skipButton.alpha = 0
            skipButton.isUserInteractionEnabled = false
        } else {
            skipButton.alpha = 1
            skipButton.isUserInteractionEnabled = true
        }
        
        return tooltipView
    }
    
    private func configureStepIndicator(in tooltipView: UIView) {
        stepIndicatorLabel.text = "\(currentIndex)/\(totalSteps)"
        stepIndicatorLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        stepIndicatorLabel.textColor = UIColor.gray
        stepIndicatorLabel.textAlignment = .right
        stepIndicatorLabel.backgroundColor = .clear
        stepIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tooltipView.addSubview(stepIndicatorLabel)
        
        NSLayoutConstraint.activate([
            stepIndicatorLabel.topAnchor.constraint(equalTo: tooltipView.topAnchor, constant: 8),
            stepIndicatorLabel.trailingAnchor.constraint(equalTo: tooltipView.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let path = UIBezierPath(rect: self.bounds)
        let targetFrame = targetView.convert(targetView.bounds, to: self)
        
        let cutoutFrame = targetFrame.insetBy(dx: -8, dy: -8)
        let cutoutPath = UIBezierPath(roundedRect: cutoutFrame, cornerRadius: 10)
        path.append(cutoutPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        self.layer.mask = maskLayer
        
        let cutoutMidX = cutoutFrame.midX
        let cutoutMidY = cutoutFrame.midY
        let cutoutTop = cutoutFrame.minY
        let cutoutBottom = cutoutFrame.maxY
        let cutoutLeft = cutoutFrame.minX
        let cutoutRight = cutoutFrame.maxX
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let isTargetNearBottom = cutoutBottom + 200 > screenHeight
        let isTargetNearTop = cutoutTop < 100
        let isTargetNearLeft = cutoutLeft < screenWidth / 3
        let isTargetNearRight = cutoutRight > 2 * (screenWidth / 3)
        
        let tooltipYPosition: CGFloat
        let gap: CGFloat = 40
        
        if isTargetNearBottom {
            tooltipYPosition = cutoutTop - 165 - gap
        } else {
            tooltipYPosition = cutoutBottom + gap
        }
        
        let tooltipView = createTooltipView(atY: tooltipYPosition)
        self.addSubview(tooltipView)
        configureStepIndicator(in: tooltipView)
        
        let imageName = getImageForScenario(isTargetNearTop: isTargetNearTop, isTargetNearBottom: isTargetNearBottom, isTargetNearLeft: isTargetNearLeft, isTargetNearRight: isTargetNearRight)
        
        var startPoint: CGPoint
        var endPoint: CGPoint
        
        switch imageName {
        case "img_dashed_coachmark_right_top":
            startPoint = CGPoint(x: cutoutLeft, y: cutoutMidY)
            endPoint = CGPoint(x: cutoutLeft - 50, y: cutoutMidY)
            
        case "img_dashed_coachmark_left_top", "img_dashed_coachmark_left_bottom":
            startPoint = CGPoint(x: cutoutRight, y: cutoutMidY)
            endPoint = CGPoint(x: cutoutRight + 50, y: cutoutMidY)
            
        case "img_dashed_coachmark_end_bottom":
            startPoint = CGPoint(x: cutoutLeft, y: cutoutMidY)
            endPoint = CGPoint(x: cutoutLeft - 50, y: cutoutMidY)
            
        case "img_dashed_coachmark_center":
            startPoint = CGPoint(x: cutoutMidX, y: cutoutBottom)
            endPoint = CGPoint(x: cutoutMidX, y: cutoutBottom + 50)
            
        case "img_dashed_coachmark_bottom":
            startPoint = CGPoint(x: cutoutMidX, y: cutoutTop)
            endPoint = CGPoint(x: cutoutMidX, y: cutoutTop - 50)
            
        default:
            startPoint = CGPoint(x: cutoutMidX, y: cutoutMidY)
            endPoint = CGPoint(x: cutoutMidX, y: cutoutMidY + 50)
        }
        
        /// 🛠 **Fix Applied:** Lift Y-position for bottom-based cutouts
        if imageName.contains("bottom"){
            startPoint.y -= 40
            endPoint.y -= 40
        }
        if imageName.contains("right_top") || imageName.contains("left_top"){
            startPoint.y += 25
            endPoint.y += 25
        }
        
        print("Finalized StartPoint: \(startPoint), EndPoint: \(endPoint)")
        
        setupDashedLine(startPoint: startPoint, endPoint: endPoint, imageName: imageName)
    }
    
    private func getImageForScenario(isTargetNearTop: Bool, isTargetNearBottom: Bool, isTargetNearLeft: Bool, isTargetNearRight: Bool) -> String {
        if isTargetNearTop {
            if isTargetNearRight {
                return "img_dashed_coachmark_right_top"
            } else if isTargetNearLeft {
                return "img_dashed_coachmark_left_top"
            }
            return "img_dashed_coachmark_top_center"
        } else if isTargetNearBottom {
            if isTargetNearLeft {
                return "img_dashed_coachmark_left_bottom"
            } else if isTargetNearRight {
                return "img_dashed_coachmark_end_bottom"
            }
            return "img_dashed_coachmark_bottom_center"
        }
        return "img_dashed_coachmark_center"
    }
    
    private func setupDashedLine(startPoint: CGPoint, endPoint: CGPoint, imageName: String) {
        let dashedImage = UIImageView(image: UIImage(named: imageName))
        
        var imageWidth: CGFloat = 25
        var imageHeight: CGFloat = 50
        
        if imageName.contains("bottom") || imageName.contains("top")   {
            imageWidth *= 1.6
            imageHeight *= 1.6
        }
        
        dashedImage.frame = CGRect(x: (startPoint.x + endPoint.x) / 2 - imageWidth / 2, y: (startPoint.y + endPoint.y) / 2 - imageHeight / 2, width: imageWidth, height: imageHeight)
        
        self.addSubview(dashedImage)
        
        print("✅ Image Loaded Successfully: \(imageName)")
        print("📌 Image Positioned at: (\(dashedImage.frame.origin.x), \(dashedImage.frame.origin.y))")
    }
    
    private func positionImageBetweenTargetAndCoachmark(startPoint: CGPoint, endPoint: CGPoint) {
        let imageWidth: CGFloat = 100
        let imageHeight: CGFloat = 50
        let midX = (startPoint.x + endPoint.x) / 2
        let midY = (startPoint.y + endPoint.y) / 2
        
        imageView.frame = CGRect(x: midX - (imageWidth / 2), y: midY - (imageHeight / 2), width: imageWidth, height: imageHeight)
        
        print("📌 Image Positioned at: (\(midX), \(midY))")
    }
    
    @objc private func skipTapped() { onSkip?(); self.removeFromSuperview() }
    @objc private func nextTapped() { onNext?(); self.removeFromSuperview() }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
