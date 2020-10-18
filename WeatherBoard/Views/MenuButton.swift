//
//  MenuButton.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 26/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import CoreGraphics
import RealmSwift

//MARK: Realm
let realm = try! Realm()
var menuItems: Results<MenuItem>?

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

extension UIView {
  func createRoundedRectPath(for rect: CGRect, radius: CGFloat) -> CGMutablePath {
    let path = CGMutablePath()
    
    // 1
    let midTopPoint = CGPoint(x: rect.midX, y: rect.minY)
    path.move(to: midTopPoint)
    
    // 2
    let topRightPoint = CGPoint(x: rect.maxX, y: rect.minY)
    let bottomRightPoint = CGPoint(x: rect.maxX, y: rect.maxY)
    let bottomLeftPoint = CGPoint(x: rect.minX, y: rect.maxY)
    let topLeftPoint = CGPoint(x: rect.minX, y: rect.minY)
    
    // 3
    path.addArc(tangent1End: topRightPoint,
      tangent2End: bottomRightPoint,
      radius: radius)

    path.addArc(tangent1End: bottomRightPoint,
      tangent2End: bottomLeftPoint,
      radius: radius)

    path.addArc(tangent1End: bottomLeftPoint,
      tangent2End: topLeftPoint,
      radius: radius)

    path.addArc(tangent1End: topLeftPoint,
      tangent2End: topRightPoint,
      radius: radius)

    // 4
    path.closeSubpath()
    
    return path
  }
    
    func drawLinearGradient(
      context: CGContext, rect: CGRect, startColor: CGColor, endColor: CGColor) {
      // 1
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      
      // 2
      let colorLocations: [CGFloat] = [0.0, 1.0]
      
      // 3
      let colors: CFArray = [startColor, endColor] as CFArray
      
      // 4
      let gradient = CGGradient(
        colorsSpace: colorSpace, colors: colors, locations: colorLocations)!

      // 5
      let startPoint = CGPoint(x: rect.midX, y: rect.minY)
      let endPoint = CGPoint(x: rect.midX, y: rect.maxY)

      context.saveGState()

      // 6
      context.addRect(rect)
      // 7
      context.clip()

      // 8
      context.drawLinearGradient(
        gradient, start: startPoint, end: endPoint, options: [])

      context.restoreGState()

    }
    

}
