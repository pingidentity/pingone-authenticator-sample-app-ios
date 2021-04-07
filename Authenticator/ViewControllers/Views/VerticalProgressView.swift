//
//  VerticalProgressView.swift
//  Authenticator
//
//  Copyright © 2020 Ping Identity. All rights reserved.
//

import Foundation
import UIKit

protocol VerticalProgressViewDelegateProtocol: class {
    func didFinishAnimation()
    func didAnimationColorChange(to color: UIColor)
}

@IBDesignable
class VerticalProgressView : UIView {
    
    @IBInspectable var berzeirPathColor : UIColor = UIColor.customBerzeirPathColor
    
    @IBInspectable var baseBackgroundColor : UIColor = UIColor.customBackgroundColor
    @IBInspectable var finaleBackgroundColor : UIColor = UIColor.customRed
    
    private var animationLayer: CAShapeLayer = CAShapeLayer()
    private static let animationLayerKeyPath = "VerticalProgressViewStroke"
    private let percentToFinale = 0.6
    var timeWindow = 30
    weak var delegate: VerticalProgressViewDelegateProtocol?
    
    private var remainderView: UIView?
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        frame = self.bounds
        
        defaultInit()
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        defaultInit()
    }
    
    private func defaultInit() {
        setupAnimationLayer()
    }
    
    private func setupAnimationLayer() {
        animationLayer.strokeColor = berzeirPathColor.cgColor
        
        animationLayer.lineWidth = self.frame.width
        animationLayer.fillColor = berzeirPathColor.cgColor
        
        self.layer.addSublayer(animationLayer)
    }
    
    func animate(with timeWindowSize: Int) {
        self.timeWindow = timeWindowSize
        removeOldAnimation()
        
        let currentTime = Date().timeIntervalSince1970
        let timePercentage = fmod(currentTime, Double(timeWindowSize))
        
        createAnimation(for: timePercentage, in: TimeInterval(timeWindowSize))
    }
    
    private func changeBackround(to color: UIColor) {
        if color == UIColor.customRed {
            guard isInFinaleTimeWindow() == true else {
                return
            }
        }
        self.delegate?.didAnimationColorChange(to: color)
        backgroundColor = color
    }
    
    func isInFinaleTimeWindow() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let timePercentage = fmod(currentTime, Double(self.timeWindow))
        return timePercentage > percentToFinale
    }
    
    private func removeOldAnimation() {
        CATransaction.begin()
        animationLayer.removeAnimation(forKey: VerticalProgressView.animationLayerKeyPath)
        if let _ = remainderView {
            self.remainderView?.removeFromSuperview()
        }
        CATransaction.commit()
    }
    
    private func createAnimation(for timePercentage: Double, in timeWindow: TimeInterval) {
        var shouldChangeToFinaleBackgroundColor = false
        
        if (timePercentage/timeWindow < percentToFinale) {
            changeBackround(to: baseBackgroundColor)
            shouldChangeToFinaleBackgroundColor = true
        }
        else {
            changeBackround(to: finaleBackgroundColor)
        }
        
        let startAnimationPercentageHeight = Double(self.frame.height) * (timePercentage / timeWindow)
        
        if timePercentage > 0 {
            remainderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(bounds.width), height: startAnimationPercentageHeight))
            remainderView?.backgroundColor = berzeirPathColor
            self.addSubview(remainderView!)
        }
        
        CATransaction.begin()

        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.width / 2, y: CGFloat(startAnimationPercentageHeight)))
        path.addLine(to: CGPoint(x:  self.bounds.width / 2, y: self.frame.height))
        
        animationLayer.path = path.cgPath

        let animation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0

        animation.duration = timeWindow - timePercentage
        if shouldChangeToFinaleBackgroundColor {
            let deadlineTime = DispatchTime.now() + animation.duration - (timeWindow * (1 - percentToFinale))
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
                guard let self = self else { return }
                self.changeBackround(to: self.finaleBackgroundColor)
            }
        }
        CATransaction.setCompletionBlock{ [weak self] in
            switch UIApplication.shared.applicationState {
            case .active:
                self?.delegate?.didFinishAnimation()
            default:
                break
            }
        }

        animationLayer.add(animation, forKey: VerticalProgressView.animationLayerKeyPath)
        CATransaction.commit()
    }
}
