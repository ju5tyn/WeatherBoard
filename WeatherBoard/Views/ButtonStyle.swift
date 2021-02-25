//
//  MenuButton.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 26/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import CoreGraphics

class ButtonStyle: UIButton {

    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var cornerRadius: CGFloat
    
    var topGradient: String?
    var bottomGradient: String?
    var textColor: UIColor? = UIColor.white
    
    required init?(coder aDecoder: NSCoder) {
        self.hue = 0.5
        self.saturation = 0.5
        self.brightness = 0.5
        self.cornerRadius = 12
      
        super.init(coder: aDecoder)
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.titleLabel?.textColor = textColor
        
        titleLabel!.layer.shadowColor = UIColor.black.cgColor
            titleLabel!.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel!.layer.shadowOpacity = 0.4
        titleLabel!.layer.shadowRadius = 5
        titleLabel!.layer.masksToBounds = false
        
        
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
      
        // 1
        let outerColor = UIColor(
            hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        //let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
      
        // 2
        let outerMargin: CGFloat = 6.0
        let outerRect = rect.insetBy(dx: outerMargin, dy: outerMargin)
        // 3
        let outerPath = createRoundedRectPath(for: outerRect, radius: cornerRadius)
      
        var outerBottom = UIColor(named: topGradient!)
        var outerTop = UIColor(named: bottomGradient!)
       
        // 4
        if state != .highlighted {
            context.saveGState()
            context.setFillColor(outerColor.cgColor)
            
            context.addPath(outerPath)
            context.fillPath()
            context.restoreGState()

            outerBottom = UIColor(named: bottomGradient!)
            outerTop = UIColor(named: topGradient!)
            
            
      }

        context.saveGState()
        context.addPath(outerPath)
        context.clip()

        drawLinearGradient(context: context, rect: outerRect,
                           startColor: outerTop!.cgColor, endColor: outerBottom!.cgColor)
        context.restoreGState()

    }
    
    @objc func hesitateUpdate() {
      setNeedsDisplay()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesMoved(touches, with: event)
      setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      setNeedsDisplay()
      
      perform(#selector(hesitateUpdate), with: nil, afterDelay: 0.1)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      setNeedsDisplay()
      
      perform(#selector(hesitateUpdate), with: nil, afterDelay: 0.1)
    }

}


