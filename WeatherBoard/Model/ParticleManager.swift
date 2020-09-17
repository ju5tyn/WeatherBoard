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
    let skScene = SKScene(size: baseView.frame.size)
    
    skScene.backgroundColor = .clear
    skScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    skScene.addChild(emitterNode)
    
    skView.backgroundColor = .clear
    skView.presentScene(skScene)
    skView.isUserInteractionEnabled = false
    skView.tag = 1
    
    
    
    emitterNode.position.y = skScene.frame.maxY
    emitterNode.particlePositionRange.dx = skScene.frame.width
    
    baseView.addSubview(skView)
    
}

func updateParticles(emitterNode: SKEmitterNode){
    
    
    
    
    
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
