//import UIKit
//
//enum SpotlightShape {
//    case circle
//    case rectangle
//    case roundedRect(cornerRadius: CGFloat)
//}
//
//struct SpotlightStep {
//    let targetView: UIView
//    let title: String
//    let subtitle: String
//    let shape: SpotlightShape
//}
//
//class SpotlightView: UIView {
//    
//    var step: SpotlightStep
//    var targetFrame: CGRect = .zero
//    var shapeFrame: CGRect = .zero
//    
//    let titleLabel = UILabel()
//    let subtitleLabel = UILabel()
//    
//    // Callback for moving to next step
//    var onDismiss: (() -> Void)?
//    
//    init(step: SpotlightStep) {
//        self.step = step
//        
//        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
//            self.targetFrame = step.targetView.convert(step.targetView.bounds, to: window)
//        }
//        
//        super.init(frame: UIScreen.main.bounds)
//        
//        backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        isUserInteractionEnabled = true
//        
//        setupLabels(title: step.title, subtitle: step.subtitle)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setupLabels(title: String, subtitle: String) {
//        titleLabel.text = title
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        titleLabel.textColor = .white
//        titleLabel.numberOfLines = 0
//        addSubview(titleLabel)
//        
//        subtitleLabel.text = subtitle
//        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
//        subtitleLabel.textColor = .white
//        subtitleLabel.numberOfLines = 0
//        addSubview(subtitleLabel)
//    }
//    
//    func positionLabels() {
//        let screenBounds = UIScreen.main.bounds
//        let padding: CGFloat = 12
//        
//        let maxWidth = screenBounds.width * 0.8
//        let titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
//        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
//        let totalHeight = titleSize.height + 8 + subtitleSize.height
//        
//        // Place below shape by default
//        var startY = shapeFrame.maxY + padding
//        
//        // If not enough space → move above
//        if startY + totalHeight > screenBounds.height {
//            startY = shapeFrame.minY - padding - totalHeight
//        }
//        
//        // Alignment logic
//        let screenMidX = screenBounds.midX
//        var titleX: CGFloat = 0
//        var subtitleX: CGFloat = 0
//        
//        if shapeFrame.midX < screenMidX * 0.7 { // Left
//            titleX = shapeFrame.minX
//            subtitleX = shapeFrame.minX
//            titleLabel.textAlignment = .left
//            subtitleLabel.textAlignment = .left
//        } else if shapeFrame.midX > screenMidX * 1.3 { // Right
//            titleX = shapeFrame.maxX - titleSize.width
//            subtitleX = shapeFrame.maxX - subtitleSize.width
//            titleLabel.textAlignment = .right
//            subtitleLabel.textAlignment = .right
//        } else { // Center
//            titleX = shapeFrame.midX - titleSize.width/2
//            subtitleX = shapeFrame.midX - subtitleSize.width/2
//            titleLabel.textAlignment = .center
//            subtitleLabel.textAlignment = .center
//        }
//        
//        // Apply frames
//        titleLabel.frame = CGRect(x: titleX, y: startY, width: titleSize.width, height: titleSize.height)
//        subtitleLabel.frame = CGRect(x: subtitleX, y: titleLabel.frame.maxY + 8, width: subtitleSize.width, height: subtitleSize.height)
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        let path = UIBezierPath(rect: rect)
//        
//        switch step.shape {
//        case .circle:
//            let diameter = max(targetFrame.width, targetFrame.height) + 24
//            shapeFrame = CGRect(
//                x: targetFrame.midX - diameter/2,
//                y: targetFrame.midY - diameter/2,
//                width: diameter,
//                height: diameter
//            )
//            path.append(UIBezierPath(ovalIn: shapeFrame))
//            
//        case .rectangle:
//            shapeFrame = targetFrame.insetBy(dx: -12, dy: -12)
//            path.append(UIBezierPath(rect: shapeFrame))
//            
//        case .roundedRect(let radius):
//            shapeFrame = targetFrame.insetBy(dx: -12, dy: -12)
//            path.append(UIBezierPath(roundedRect: shapeFrame, cornerRadius: radius))
//        }
//        
//        path.usesEvenOddFillRule = true
//        
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        maskLayer.fillRule = .evenOdd
//        layer.mask = maskLayer
//        
//        // Position labels now
//        positionLabels()
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        removeFromSuperview()
//        onDismiss?()
//    }
//}
//
//class Spotlight {
//    
//    var steps: [SpotlightStep] = []
//    var currentIndex = 0
//    
//    func show(steps: [SpotlightStep]) {
//        guard !steps.isEmpty else { return }
//        self.steps = steps
//        self.currentIndex = 0
//        showStep()
//    }
//    
//    @MainActor
//    func showStep() {
//        guard currentIndex < steps.count else { return }
//        let step = steps[currentIndex]
//        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
//            let spotlight = SpotlightView(step: step)
//            spotlight.onDismiss = {
//                currentIndex += 1
//                showStep()
//            }
//            window.addSubview(spotlight)
//        }
//    }
//    
//    // Convenience for single step
//    func show(over view: UIView, title: String, subtitle: String, shape: SpotlightShape = .circle) {
//        let step = SpotlightStep(targetView: view, title: title, subtitle: subtitle, shape: shape)
//        show(steps: [step])
//    }
//}


import UIKit

// MARK: - Models

public enum SpotlightShape {
    case circle
    case rectangle
    case roundedRect(cornerRadius: CGFloat)
}

public struct SpotlightStep {
    public let targetView: UIView
    public let title: String
    public let subtitle: String
    public let shape: SpotlightShape

    public init(targetView: UIView, title: String, subtitle: String, shape: SpotlightShape) {
        self.targetView = targetView
        self.title = title
        self.subtitle = subtitle
        self.shape = shape
    }
}

// MARK: - SpotlightView (UI overlay)

@MainActor
public final class SpotlightView: UIView {

    // step (public so caller/manager can pass it)
    public let step: SpotlightStep

    // frames
    public private(set) var targetFrame: CGRect = .zero
    public private(set) var shapeFrame: CGRect = .zero

    // labels (accessible by manager to change color if needed)
    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()

    // callback to signal dismissal (tap -> next)
    public var onDismiss: (() -> Void)?

    // MARK: - Init

    public init(step: SpotlightStep) {
        self.step = step
        super.init(frame: UIScreen.main.bounds)

        // compute targetFrame in window coordinates (best-effort)
        if let window = step.targetView.window ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            self.targetFrame = step.targetView.convert(step.targetView.bounds, to: window)
        } else if let superview = step.targetView.superview {
            // fallback: convert relative to screen coordinate space
            self.targetFrame = superview.convert(step.targetView.frame, to: nil)
        } else {
            self.targetFrame = step.targetView.frame
        }

        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        isUserInteractionEnabled = true

        setupLabels(title: step.title, subtitle: step.subtitle)
        // Ensure a draw is scheduled so mask + labels will appear
        setNeedsDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Labels

    private func setupLabels(title: String, subtitle: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        addSubview(subtitleLabel)
    }

    // MARK: - Layout / Positioning

    /// Positions labels relative to the spotlight `shapeFrame`
    private func positionLabels() {
        let screenBounds = UIScreen.main.bounds
        let padding: CGFloat = 12

        let maxWidth = screenBounds.width * 0.8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let totalHeight = titleSize.height + 8 + subtitleSize.height

        // default: below the spotlight shape
        var startY = shapeFrame.maxY + padding

        // if not enough space below, move above the shape
        if startY + totalHeight > screenBounds.height {
            startY = shapeFrame.minY - padding - totalHeight
        }

        // alignment logic: left / center / right based on shape midX
        let screenMidX = screenBounds.midX
        var titleX: CGFloat = 0
        var subtitleX: CGFloat = 0

        // thresholds tuned to match expected behavior
        if shapeFrame.midX < screenMidX * 0.7 { // left side -> left align
            titleX = max(12, shapeFrame.minX) // keep some margin
            subtitleX = titleX
            titleLabel.textAlignment = .left
            subtitleLabel.textAlignment = .left
        } else if shapeFrame.midX > screenMidX * 1.3 { // right side -> right align
            let tr = min(screenBounds.width - 12, shapeFrame.maxX)
            titleX = tr - titleSize.width
            subtitleX = tr - subtitleSize.width
            titleLabel.textAlignment = .right
            subtitleLabel.textAlignment = .right
        } else { // center
            titleX = shapeFrame.midX - (titleSize.width / 2)
            subtitleX = shapeFrame.midX - (subtitleSize.width / 2)
            titleLabel.textAlignment = .center
            subtitleLabel.textAlignment = .center
        }

        // apply frames
        titleLabel.frame = CGRect(x: titleX, y: startY, width: min(titleSize.width, maxWidth), height: titleSize.height)
        subtitleLabel.frame = CGRect(x: subtitleX, y: titleLabel.frame.maxY + 8, width: min(subtitleSize.width, maxWidth), height: subtitleSize.height)
    }

    // MARK: - Drawing / Mask

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        // base path covers whole view
        let path = UIBezierPath(rect: rect)

        // determine shapeFrame and append desired cutout
        switch step.shape {
        case .circle:
            let diameter = max(targetFrame.width, targetFrame.height) + 24
            shapeFrame = CGRect(
                x: targetFrame.midX - diameter / 2,
                y: targetFrame.midY - diameter / 2,
                width: diameter,
                height: diameter
            )
            path.append(UIBezierPath(ovalIn: shapeFrame))

        case .rectangle:
            shapeFrame = targetFrame.insetBy(dx: -12, dy: -12)
            path.append(UIBezierPath(rect: shapeFrame))

        case .roundedRect(let radius):
            shapeFrame = targetFrame.insetBy(dx: -12, dy: -12)
            path.append(UIBezierPath(roundedRect: shapeFrame, cornerRadius: radius))
        }

        path.usesEvenOddFillRule = true

        // apply mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer

        // now position labels relative to shapeFrame
        positionLabels()
    }

    // reposition on rotation / layout changes
    public override func layoutSubviews() {
        super.layoutSubviews()

        // recompute targetFrame in case view moved/rotated
        if let window = step.targetView.window ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            self.targetFrame = step.targetView.convert(step.targetView.bounds, to: window)
        } else if let superview = step.targetView.superview {
            self.targetFrame = superview.convert(step.targetView.frame, to: nil)
        }

        // force redraw so the mask and labels update for new size/orientation
        setNeedsDisplay()
    }

    // MARK: - Interaction

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss overlay and notify manager
        removeFromSuperview()
        onDismiss?()
    }
}

// MARK: - Controller to sequence multiple steps

public final class Spotlight {

    public var steps: [SpotlightStep] = []
    public var currentIndex = 0

    public init() {}

    /// Show an array of steps in sequence. Safe to call from background — it will switch to Main actor.
    public func show(steps: [SpotlightStep]) {
        guard !steps.isEmpty else { return }
        self.steps = steps
        self.currentIndex = 0

        // ensure we call the actor-isolated method on the main actor
        Task { @MainActor in
            await self.showStep()
        }
    }

    @MainActor
    public func showStep() async {
        guard currentIndex < steps.count else { return }
        let step = steps[currentIndex]

        // find key window safely (main actor)
        if let window = step.targetView.window ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {

            let spotlightView = SpotlightView(step: step)

            // onDismiss must capture self weakly to avoid retain cycles
            spotlightView.onDismiss = { [weak self] in
                guard let self = self else { return }
                self.currentIndex += 1
                Task { @MainActor in
                    await self.showStep()
                }
            }

            window.addSubview(spotlightView)
        }
    }

    // Convenience single-step API
    public func show(over view: UIView, title: String, subtitle: String, shape: SpotlightShape = .circle) {
        let step = SpotlightStep(targetView: view, title: title, subtitle: subtitle, shape: shape)
        show(steps: [step])
    }
}
