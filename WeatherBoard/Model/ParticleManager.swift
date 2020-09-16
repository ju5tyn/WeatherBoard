//
//  ParticleManager.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 29/08/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import SpriteKit

//MARK: AddParticles
func setParticles(baseView: UIView, emitterNode: SKEmitterNode) {
    
    
    let skView = SKView(frame: CGRect(x:0, y:-200, width: baseView.frame.width, height: baseView.frame.height))
    let scene = SKScene(size: baseView.frame.size)
    
    scene.backgroundColor = .clear
    scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    scene.addChild(emitterNode)
    
    skView.backgroundColor = .clear
    skView.presentScene(scene)
    skView.isUserInteractionEnabled = false
    skView.tag = 1
    
    
    
    emitterNode.position.y = scene.frame.maxY
    emitterNode.particlePositionRange.dx = scene.frame.width
    
    baseView.addSubview(skView)
    
}

//MARK: RemoveParticles
func removeParticles(view: UIView) {
    
    
    
    if let viewWithTag = view.viewWithTag(1){
        viewWithTag.removeFromSuperview()
        
        
        print("Rain Removed")
    }else{
        print("error removing rain")
    }
    
}

func hideParticles(view: UIView) {
    
    if let viewWithTag = view.viewWithTag(1){
        viewWithTag.isHidden = true
    }else{
        print("error hiding particles")
    }
    
}

func showParticles(view: UIView) {
    
    if let viewWithTag = view.viewWithTag(1){
        viewWithTag.isHidden = false
    }else{
        print("error showing particles")
    }
    
}
