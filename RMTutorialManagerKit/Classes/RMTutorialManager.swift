//
//  RMTutorialManager.swift
//  SaveMoney
//
//  Created by ricocheng on 2023/7/23.
//

import UIKit

public enum Position {
    case top
    case left
    case bottom
    case right
}

public class RMTutorialManager {
    
    public static func add(itemView: UIView, tipText: String, position: Position, identifier: String) {
        let model: RMTutorialModel = RMTutorialModel.init(itemView: itemView, tipText: tipText, position: position, identifier: identifier)
        if UserDefaults.standard.object(forKey: RMTutorialManager.Tutorial_Queue_Key) == nil {
            UserDefaults.standard.set(tutorialQueueKeys, forKey: RMTutorialManager.Tutorial_Queue_Key)
            UserDefaults.standard.synchronize()
        } else {
            tutorialQueueKeys = UserDefaults.standard.object(forKey: RMTutorialManager.Tutorial_Queue_Key) as! [String]
        }
        if !tutorialQueueKeys.contains(model.itemView.tutorialKey) {
            queue.append(model)
            if maskView == nil {
                showNext()
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
                self.maskView!.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    private static let Tutorial_Queue_Key: String = "Tutorial_Queue"
    
    private static var queue: [RMTutorialModel] = []
    
    private static var maskView: RMTutorialMaskView?
    
    private static var tutorialQueueKeys: [String] = []
    
    private static func showNext() {
        guard let model = queue.first else { return }
        
        // Create the MaskView
        let maskView = RMTutorialMaskView(frame: UIScreen.main.bounds, model: model)
        UIApplication.shared.windows.first?.addSubview(maskView)
        self.maskView = maskView
    }
    
    @objc private static func dismiss() {
        tutorialQueueKeys.append((queue.first?.itemView.tutorialKey)!)
        UserDefaults.standard.set(tutorialQueueKeys, forKey: RMTutorialManager.Tutorial_Queue_Key)
        UserDefaults.standard.synchronize()
        maskView?.removeFromSuperview()
        maskView = nil
        queue.removeFirst()
        if !queue.isEmpty {
            showNext()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            self.maskView!.addGestureRecognizer(tapGesture)
        }
    }
    
    private class RMTutorialMaskView: UIView {
        private let model: RMTutorialModel
        
        init(frame: CGRect, model: RMTutorialModel) {
            self.model = model
            super.init(frame: frame)
            backgroundColor = UIColor.black.withAlphaComponent(0.8)
            
            label.text = model.tipText
            label.sizeToFit()
            addSubview(label)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private var label: UILabel = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .boldSystemFont(ofSize: 18)
            view.textColor = UIColor.white
            return view
        }()
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            // Set the fill color to black with alpha 0.8
            UIColor.black.withAlphaComponent(0.8).setFill()
            
            // Fill the entire view with black background
            UIRectFill(rect)
            
            // Find the absolute position of the itemView
            let itemViewPosition = model.itemView.convert(model.itemView.bounds, to: self)
            
            switch model.position {
            case .top:
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: model.itemView.topAnchor, constant: -label.frame.height - 5),
                    label.centerXAnchor.constraint(equalTo: model.itemView.centerXAnchor)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    label.leftAnchor.constraint(equalTo: model.itemView.rightAnchor, constant: 5),
                    label.centerYAnchor.constraint(equalTo: model.itemView.centerYAnchor)
                ])
            case .left:
                NSLayoutConstraint.activate([
                    label.rightAnchor.constraint(equalTo: model.itemView.leftAnchor, constant: -5),
                    label.centerYAnchor.constraint(equalTo: model.itemView.centerYAnchor)
                ])
            case .bottom:
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: model.itemView.bottomAnchor, constant: 5),
                    label.centerXAnchor.constraint(equalTo: model.itemView.centerXAnchor)
                ])
            }
            
            // Create the path for the itemView
            let itemViewPath = UIBezierPath(rect: itemViewPosition)
            
            // Create the path for the transparent circle
            let radius = max(model.itemView.bounds.width, model.itemView.bounds.height) / 2
            let transparentCirclePath = UIBezierPath(roundedRect: rect, cornerRadius: 0)
            transparentCirclePath.append(UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: itemViewPosition.midX - radius, y: itemViewPosition.minY - radius), size: CGSize(width: radius * 2, height: radius * 2)), cornerRadius: radius))
            transparentCirclePath.usesEvenOddFillRule = true
            
            // Set the fill color to clear
            UIColor.clear.setFill()
            
            // Fill the path, which will create the circular cutout
            transparentCirclePath.fill()
            
            // Set the blending mode to clear, so the itemView and the cutout areas become transparent
            context.setBlendMode(.clear)
            UIColor.clear.setFill()
            
            // Fill the itemView path using the clear blend mode
            itemViewPath.fill()
        }
    }
}

internal class RMTutorialModel {
    var itemView: UIView
    var tipText: String
    var position: Position
    var identifier: String
    
    init(itemView: UIView, tipText: String, position: Position, identifier: String) {
        self.itemView = itemView
        self.tipText = tipText
        self.position = position
        self.itemView.tutorialKey = identifier
        self.identifier = identifier
    }
}

private var tutorialKeyAssociationKey: UInt8 = 0

private extension UIView {

    var tutorialKey: String {
        get {
            return objc_getAssociatedObject(self, &tutorialKeyAssociationKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &tutorialKeyAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

