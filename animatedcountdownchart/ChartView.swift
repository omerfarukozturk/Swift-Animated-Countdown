//
//  ChartView.swift
//  animatedcountdownchart
//
//  Created by Ömer Faruk Öztürk on 31.03.2018.
//  Copyright © 2018 omerfarukozturk. All rights reserved.
//

import Foundation
import UIKit

class ChartView : UIView {
    private var circleLayer: CAShapeLayer!
    
    // Fill color of the arc
    private var arcFillColor = UIColor.orange
    
    // Background fill color of the arc
    private var arcBackgroundColor = UIColor.lightGray
    
    // Total angle of the arc
    private var totalAngle : CGFloat = 210.0
    
    // Thickness of the arc
    private var arcWidth: CGFloat = 5.0
    
    // Calculated angle of the full arc
    private var fullCircleAngle : CGFloat {
        get {
            return 2 * CGFloat(Double.pi) * (self.totalAngle / 360)
        }
    }
    
    // Calculated center of the arc
    private var arcCenter : CGPoint {
        get {
            return CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        }
    }
    
    // Calculated radius of the arc
    private var radius : CGFloat {
        get {
            let rect = self.frame
            var radius: CGFloat = 0
            if rect.width > rect.height {
                radius = (rect.width - arcWidth) / 2.0
            }else{
                radius = (rect.height - arcWidth) / 2.0
            }
            return radius
        }
    }
    
    // Calculated start angle of the arc
    private var startAngle : CGFloat {
        get {
            return CGFloat(Double.pi) * (1 - (self.totalAngle - 180)/360)
        }
    }
    
    // End angle of arc path
    private var endAngle : CGFloat {
        get {
            return startAngle + fullCircleAngle
        }
    }
    
    func initializeView(arcWidth: CGFloat = 5.0, arcFillColor: UIColor = .orange, arcBackgroundColor: UIColor = .lightGray, fullArcAngle : CGFloat = 210.0){
        self.backgroundColor = UIColor.clear

        self.arcWidth = arcWidth
        self.arcFillColor = arcFillColor
        self.arcBackgroundColor = arcBackgroundColor
        
        var fullAngle = fullArcAngle
        if fullAngle > 360 {
            fullAngle = 360
        }
        self.totalAngle = fullAngle
        
        
        // Ard background layer
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let backgroundCircleLayer = CAShapeLayer()
        backgroundCircleLayer.path = circlePath.cgPath
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = self.arcBackgroundColor.cgColor
        backgroundCircleLayer.lineWidth = self.arcWidth
        backgroundCircleLayer.lineCap = kCALineCapRound
        
        // Draw & add background layer
        backgroundCircleLayer.strokeEnd = 1.0
        layer.addSublayer(backgroundCircleLayer)
        
        // Arc foreground layer
        let statusCirclePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        circleLayer = CAShapeLayer()
        circleLayer.path = statusCirclePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = self.arcFillColor.cgColor
        circleLayer.lineWidth = self.arcWidth
        circleLayer.lineCap = kCALineCapRound
        
        // Draw & add background layer
        circleLayer.strokeEnd = 1.0
        layer.addSublayer(circleLayer)
    }
    
    func animateCircle(toRatio: Double) {
        
        if self.circleLayer == nil {
            print("To animate chart, initialize ChartView first by calling initializeView().")
            return
        }
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // set circle animation timing function
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.775, 0, 0.178, 1)
        
        // Set the animation duration appropriately
        animation.duration = 1.2
        
        // Animate from 1 (full circle), ratio (0 : no circle).
        animation.fromValue = 1
        animation.toValue = toRatio
        
        // Set the circleLayer's strokeEnd property to <ratio>. It's the right value when the animation ends.
        circleLayer.strokeEnd = CGFloat(toRatio)
        
        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
    }
}
