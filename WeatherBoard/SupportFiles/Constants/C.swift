//
//  Constants.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 16/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

//Enum for pages, easier to read than previous int system used
enum Pages: CaseIterable {
    case today, tomorrow, more
    
    mutating func next() {
        let allCases = type(of: self).allCases
        self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
    }
    
    mutating func prev() {
        let allCases = type(of: self).allCases
        self = allCases[(allCases.firstIndex(of: self)! - 1) % allCases.count]
    }
}

struct C {
    
    
    
    static let cellIdentifier = "MenuCell"
     
    static let mainURL = "https://api.openweathermap.org/data/2.5/onecall?&appid="
    
    struct units{
        static let metric = "&units=metric"
        static let imperial = "&units=imperial"
    }
    
    struct defaults{
        static let units = "units"
        static let defaultToGPS = "defaultTolocation"
        static let defaultLocation = "defaultLocation"
    }
    
    
    
    struct segues{
        
        static let menuToMain = "toMain"
        static let mainToMenu = "toMenu"
        static let mainToWeather = "toWeather"
        static let mainToDetails = "toDetails"
        static let menuToAbout = "toAbout"
        static let menuToSettings = "toSettings"
        
    }
    
    struct particles{
        
        static let rainParticle = "RainParticle.sks"
        static let snowParticle = "SnowParticle.sks"
        static let stormParticle = "StormParticle.sks"
        static let starParticle = "StarParticle.sks"
        static let starParticleCloudy = "StarParticleCloudy.sks"
        
    }
    
    
}
