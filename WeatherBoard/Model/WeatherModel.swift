//
//  WeatherModel.swift
//  Clima
//
//  Created by Justyn Henman on 07/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel{
    
    //MARK: global attributes
    let timeZone: Int
    let cityName: String
    let sunrise: Int
    let sunset: Int
    let dt: Int
    
    
    let conditionID: [Int]
    let temperature: [Double]
    let description: [String]
    
    var tempString: [String] {
        return [String(format: "%.0f", temperature[0]), String(format: "%.0f", temperature[1]), String(format: "%.0f", temperature[2])]
    }
    
    var conditionName: [String] {
        
        return [getIconName(conditionID[0]), getIconName(conditionID[1]), getIconName(conditionID[2])]
        
    }
    
    //MARK: global calculated
    
    var timeString: String {
        
        //returns time from selected location
        return Date(timeInterval: TimeInterval(timeZone), since: Date()).UTCTimeString
        
    }
    
    var isDay: Bool {
        
        if(dt>sunrise && dt<sunset){
            return true
        }else{
            return false
        }
        
    }
    
    var isDayString: String{
        
        if isDay{
            return "day"
        }else{
            return "night"
        }
        
    }
    
    var particleToDisplay: [String?]{
        
        return [getParticleName(conditionID[0]), getParticleName(conditionID[1]), getParticleName(conditionID[2])]
        
    }
    
    func getParticleName(_ conditionID: Int) -> String? {
        
        let iconName = getIconName(conditionID)
        
        switch iconName{
        
        case "rain", "rain_clouds", "shower_rain":
            return Constants.particles.rainParticle
            
        case "thunderstorm":
            return Constants.particles.stormParticle
            
        case "snow":
            return Constants.particles.snowParticle
            
        case "clear":
            if isDay{
                return nil
            }else{
                return Constants.particles.starParticle
            }
            
        default:
            return nil
        }
        
        
        
        
        
    }
    
    func getIconName(_ conditionID: Int) -> String{
        
        switch conditionID{
            
            //add on night day after
            
            case 200...299:
                return "thunderstorm"
            
            case 300...399:
                return "rain"
            
            case 501...502:
                return "rain_clouds"
            
            case 503...504:
                return "rain"
            
            case 511:
                return "snow"
            
            case 520...599:
                return "shower_rain"
            
            case 600...699:
                return "snow"
            
            case 701...711:
                return "mist"
            
            case 721:
                return "mist"
            
            case 731, 761, 762:
                return "mist"
        
            case 741, 751, 771:
                return "mist"
        
            case 781:
                return "thunderstorm"
        
            case 800:
                return "clear"
        
            case 801...804:
                return "scattered_clouds"

            default:
                return "scattered_clouds"
            
        }
        
    }
    
    

}

extension Date {

   var UTCTimeString: String {
        
        //dateformatter for time thing
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "H:mm"
    
        return formatter.string(from: self)
    
    }
    
    
}
