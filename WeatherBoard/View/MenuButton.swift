//
//  MenuButton.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 26/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

class MenuButton: UIButton {

    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    
    
    
    required init?(coder aDecoder: NSCoder) {
        self.hue = 0.5
        self.saturation = 0.5
        self.brightness = 0.5
        
      
        super.init(coder: aDecoder)
        
        self.titleLabel!.font = UIFont(name: "SF-Compact-Text-Bold.otf", size: 20)
        
        self.isOpaque = false
        self.backgroundColor = .clear
        
        
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
      
        // 1
        let outerColor = UIColor(
            hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
      
        // 2
        let outerMargin: CGFloat = 5.0
        let outerRect = rect.insetBy(dx: outerMargin, dy: outerMargin)
        // 3
        let outerPath = createRoundedRectPath(for: outerRect, radius: 12.0)
      
        var outerTop = UIColor(named: "grad_clear_night_top")
        var outerBottom = UIColor(named: "grad_clear_night_bottom")
       
        // 4
        if state != .highlighted {
            context.saveGState()
            context.setFillColor(outerColor.cgColor)
            
            context.addPath(outerPath)
            context.fillPath()
            context.restoreGState()
            
            context.setShadow(offset: CGSize(width: 0, height: 2),
            blur: 3.0, color: shadowColor.cgColor)
            
            outerTop = UIColor(named: "grad_clear_night_bottom")
            outerBottom = UIColor(named: "grad_clear_night_top")
            
            
      }
        
        // Outer Path Gradient:
        
        // 1
        //let outerTop = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        
        //let outerBottom = UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: 1.0)

        
        
        // 2
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
