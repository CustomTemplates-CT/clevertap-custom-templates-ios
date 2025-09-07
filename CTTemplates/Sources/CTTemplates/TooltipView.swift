import UIKit

enum TooltipGravity {
    case top, bottom, left, right
}

final class TooltipView: UIView {
    
    var bubbleColor: UIColor
    var bubbleTextColor: UIColor
    var cornerRadius: CGFloat = 10
    var arrowWidth: CGFloat = 10
    var arrowHeight: CGFloat = 12
    var contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    var spacingFromTarget: CGFloat = 8
    var gravity: TooltipGravity = .right
    
    let label = UILabel()
    
    init(message: String, gravity: TooltipGravity, bubbleColor: UIColor = .systemRed, bubbleTextColor: UIColor = .white) {
        self.bubbleColor = bubbleColor
        self.bubbleTextColor = bubbleTextColor
        self.gravity = gravity
        super.init(frame: .zero)
        backgroundColor = .clear
        
        label.text = message
        label.textColor = bubbleTextColor
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        switch gravity {
        case .left:
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right - arrowWidth)
            ])
        case .right:
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: arrowWidth + contentInsets.left),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
            ])
        case .top:
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom - arrowHeight),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: arrowHeight + contentInsets.top),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
            ])
        }
        
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let w = rect.width
        let h = rect.height
        let path = UIBezierPath()
        let radius = cornerRadius
        
        switch gravity {
        case .left:
            let bubbleRect = CGRect(x: 0, y: 0, width: w - arrowWidth, height: h)
            path.append(UIBezierPath(roundedRect: bubbleRect, cornerRadius: radius))
            let tri = UIBezierPath()
            tri.move(to: CGPoint(x: bubbleRect.maxX, y: h/2 - arrowHeight/2))
            tri.addLine(to: CGPoint(x: w, y: h/2))
            tri.addLine(to: CGPoint(x: bubbleRect.maxX, y: h/2 + arrowHeight/2))
            tri.close()
            path.append(tri)
            
        case .right:
            let bubbleRect = CGRect(x: arrowWidth, y: 0, width: w - arrowWidth, height: h)
            path.append(UIBezierPath(roundedRect: bubbleRect, cornerRadius: radius))
            let tri = UIBezierPath()
            tri.move(to: CGPoint(x: bubbleRect.minX, y: h/2 - arrowHeight/2))
            tri.addLine(to: CGPoint(x: 0, y: h/2))
            tri.addLine(to: CGPoint(x: bubbleRect.minX, y: h/2 + arrowHeight/2))
            tri.close()
            path.append(tri)
            
            // <-- swapped drawing for top/bottom so arrow orientation matches placement -->
        case .top:
            // Tooltip sits above target -> arrow should point down (arrow at bottom of tooltip)
            let bubbleRect = CGRect(x: 0, y: 0, width: w, height: h - arrowHeight)
            path.append(UIBezierPath(roundedRect: bubbleRect, cornerRadius: radius))
            let tri = UIBezierPath()
            tri.move(to: CGPoint(x: w/2 - arrowWidth/2, y: bubbleRect.maxY))
            tri.addLine(to: CGPoint(x: w/2, y: h))
            tri.addLine(to: CGPoint(x: w/2 + arrowWidth/2, y: bubbleRect.maxY))
            tri.close()
            path.append(tri)
            
        case .bottom:
            // Tooltip sits below target -> arrow should point up (arrow at top of tooltip)
            let bubbleRect = CGRect(x: 0, y: arrowHeight, width: w, height: h - arrowHeight)
            path.append(UIBezierPath(roundedRect: bubbleRect, cornerRadius: radius))
            let tri = UIBezierPath()
            tri.move(to: CGPoint(x: w/2 - arrowWidth/2, y: bubbleRect.minY))
            tri.addLine(to: CGPoint(x: w/2, y: 0))
            tri.addLine(to: CGPoint(x: w/2 + arrowWidth/2, y: bubbleRect.minY))
            tri.close()
            path.append(tri)
        }
        
        bubbleColor.setFill()
        path.fill()
    }
    
    static func show(message: String, for target: UIView, in container: UIView, gravity requestedGravity: TooltipGravity, bubbleColor: UIColor = .systemRed, bubbleTextColor: UIColor = .white, completion: (() -> Void)? = nil) {
        container.layoutIfNeeded()
        target.superview?.layoutIfNeeded()
        
        // Temporary tip for sizing
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.font = .systemFont(ofSize: 14, weight: .semibold)
        temp.text = message
        let maxTextWidth: CGFloat = 220
        let textSize = temp.sizeThatFits(CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude))
        
        var gravity = requestedGravity
        var width = textSize.width + 12 + 12
        var height = textSize.height + 8 + 8
        
        // add arrow padding
        switch gravity {
        case .left, .right: width += 10
        case .top, .bottom: height += 12
        }
        
        let targetFrame = target.superview?.convert(target.frame, to: container) ?? target.frame
        
        // --- Auto Flip Logic ---
        let availableAbove = targetFrame.minY - container.safeAreaInsets.top
        let availableBelow = container.bounds.height - targetFrame.maxY - container.safeAreaInsets.bottom
        let availableLeft = targetFrame.minX - container.safeAreaInsets.left
        let availableRight = container.bounds.width - targetFrame.maxX - container.safeAreaInsets.right
        
        if gravity == .top && availableAbove < height + 8 {
            gravity = .bottom
        } else if gravity == .bottom && availableBelow < height + 8 {
            gravity = .top
        } else if gravity == .left && availableLeft < width + 8 {
            gravity = .right
        } else if gravity == .right && availableRight < width + 8 {
            gravity = .left
        }
        
        let tip = TooltipView(message: message, gravity: gravity, bubbleColor: bubbleColor, bubbleTextColor: bubbleTextColor)
        tip.alpha = 0
        container.addSubview(tip)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch gravity {
        case .right:
            x = targetFrame.maxX + tip.spacingFromTarget
            y = targetFrame.midY - height/2
        case .left:
            x = targetFrame.minX - width - tip.spacingFromTarget
            y = targetFrame.midY - height/2
        case .top:
            x = targetFrame.midX - width/2
            y = targetFrame.minY - height - tip.spacingFromTarget
        case .bottom:
            x = targetFrame.midX - width/2
            y = targetFrame.maxY + tip.spacingFromTarget
        }
        
        tip.frame = CGRect(x: x, y: y, width: width, height: height)
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut], animations: {
            tip.alpha = 1
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIView.animate(withDuration: 0.5, animations: {
                    tip.alpha = 0
                }, completion: { _ in
                    tip.removeFromSuperview()
                    completion?()
                })
            }
        })
    }
}
