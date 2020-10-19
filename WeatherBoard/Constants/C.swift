//
//  Constants.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 16/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

struct C {
    
    static let cellIdentifier = "MenuCell"
    
    static let mainURL = "https://api.openweathermap.org/data/2.5/forecast?units=metric&appid="
    
    
    
    struct segues{
        
        static let menuToMain = "toMain"
        static let mainToMenu = "toMenu"
        
    }
    
    struct particles{
        
        static let rainParticle = "RainParticle.sks"
        static let snowParticle = "SnowParticle.sks"
        static let stormParticle = "StormParticle.sks"
        static let starParticle = "StarParticle.sks"
        static let starParticleCloudy = "StarParticleCloudy.sks"
        
    }
    
    
}
