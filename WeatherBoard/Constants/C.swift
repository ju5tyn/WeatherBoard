//
//  Constants.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 16/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

struct C {
    
    static let cellIdentifier = "MenuCell"
     
    static let mainURL = "https://api.openweathermap.org/data/2.5/onecall?&appid="
    
    struct units{
        static let metric = "&units=metric"
        static let imperial = "&units=imperial"
    }
    
    
    
    
    struct segues{
        
        static let menuToMain = "toMain"
        static let mainToMenu = "toMenu"
        static let mainToWeather = "toWeather"
        static let mainToDetails = "toDetails"
        static let menuToAbout = "toAbout"
        static let aboutToMenu = "aboutToMenu"
        
    }
    
    struct particles{
        
        static let rainParticle = "RainParticle.sks"
        static let snowParticle = "SnowParticle.sks"
        static let stormParticle = "StormParticle.sks"
        static let starParticle = "StarParticle.sks"
        static let starParticleCloudy = "StarParticleCloudy.sks"
        
    }
    
    
}
