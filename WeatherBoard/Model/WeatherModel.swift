//
//  WeatherModel.swift
//  Clima
//
//  Created by Justyn Henman on 07/07/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

/*
 struct WeatherModel{
 //edit
 //MARK: global attributes
 let timeZone: Int
 let cityName: String
 let sunrise: Int
 let sunset: Int
 let dt: Double
 let isCurrentLocation: Bool
 let doNotSave: Bool
 
 let conditionID: [Int]
 
 let fiveDayArray: [fiveDay]
 
 //5day forecast
 
 struct fiveDay{
 
 let conditionID: Int
 
 let dt: Double
 
 var dayString: String{
 
 let date = Date(timeIntervalSince1970: dt)
 let dateFormatter = DateFormatter()
 dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
 dateFormatter.locale = NSLocale.current
 dateFormatter.dateFormat = "EEEE" //Specify your format that you want
 
 return dateFormatter.string(from: date)
 
 }
 
 
 var conditionName: String{
 return getIconName(conditionID)
 }
 
 let description: String
 
 let temp: Double
 var tempString: String{
 return "\(String(format: "%.0f", temp))°"
 }
 
 let highTemp: Double
 var highTempString: String{
 return "\(String(format: "%.0f", temp))°"
 }
 
 let lowTemp: Double
 var lowTempString: String{
 return "\(String(format: "%.0f", temp))°"
 }
 
 let cloudCover: Int
 var cloudCoverString: String{
 return "\(cloudCover)%"
 }
 
 let windSpeed: Double
 var windSpeedString: String{
 return String(format: "%.1fM/S", Double(windSpeed))
 }
 
 let windDirection: Double
 var windDirectionString: String{
 return windDirection.direction.description.uppercased()
 }
 
 let precip: Double
 var precipString: String{
 return "\(String(format: "%.0f", precip*100))%"
 }
 
 
 let visibility: Double
 // this is in metres
 // below returns visibility string in KM
 var visibilityString: String{
 return String(format: "%.0fKM", Double(visibility/1000))
 }
 
 }
 
 //MARK: global calculated
 
 var timeString: String {
 
 //returns time from selected location
 return Date(timeInterval: TimeInterval(timeZone), since: Date()).UTCTimeString
 
 }
 
 var isDay: Bool {
 
 return (Int(dt)>sunrise && Int(dt)<sunset) ? true : false
 
 }
 
 var isDayString: String{
 
 return isDay ? "day" : "night"
 
 }
 
 var particleToDisplay: [String?]{
 
 return [getParticleName(conditionID[0]),
 getParticleName(conditionID[1])]
 
 }
 
 func getParticleName(_ conditionID: Int) -> String? {
 
 let iconName = getIconName(conditionID)
 
 switch iconName{
 
 case "rain", "rain_clouds", "shower_rain":
 return C.particles.rainParticle
 
 case "thunderstorm":
 return C.particles.stormParticle
 
 case "snow":
 return C.particles.snowParticle
 
 case "clear", "few_clouds":
 if self.isDay{
 return nil
 }else{
 return C.particles.starParticle
 }
 
 case "scattered_clouds", "broken_clouds":
 if self.isDay{
 return nil
 }else{
 return C.particles.starParticleCloudy
 }
 
 default:
 return nil
 }
 
 }
 
 }
 
 
 
 func getIconName(_ conditionID: Int) -> String{
 
 //print(conditionID)
 
 switch conditionID{
 
 //add on night day after
 
 case 200...299:
 return "thunderstorm"
 
 case 300...399:
 return "rain"
 
 case 500...504:
 return "rain_clouds"
 
 case 511:
 return "snow"
 
 case 520...599:
 return "shower_rain"
 
 case 600...699:
 return "snow"
 
 case 700...780:
 return "mist"
 
 case 781:
 return "thunderstorm"
 
 case 800:
 return "clear"
 
 case 801:
 return "few_clouds"
 
 case 802...803:
 return "scattered_clouds"
 
 case 804...804:
 return "broken_clouds"
 
 default:
 return "scattered_clouds"
 
 }
 
 }
 
 enum Direction: String {
 case n, nne, ne, ene, e, ese, se, sse, s, ssw, sw, wsw, w, wnw, nw, nnw
 }
 
 extension Direction: CustomStringConvertible  {
 static let all: [Direction] = [.n, .nne, .ne, .ene, .e, .ese, .se, .sse, .s, .ssw, .sw, .wsw, .w, .wnw, .nw, .nnw]
 init(_ direction: Double) {
 let index = Int((direction + 11.25).truncatingRemainder(dividingBy: 360) / 22.5)
 self = Direction.all[index]
 }
 var description: String {
 return rawValue.uppercased()
 }
 }
 
 extension Double {
 var direction: Direction {
 return Direction(self)
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
 
 */


struct WeatherModel{
    
    let lat: Double
    let lon: Double
    
    var locationName: String? {
        var name: String?
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon), completionHandler: { placemarks, error in
            
            //if let validName = placemarks?.first?.locality{ name = validName; print(validName) }
            name = placemarks?.first?.locality
            print(name)
            
        })
        print("\(name) is THE LOCATION NAME ")
        
        
        return name
    }
    //converts search to lat+lon
    let timeZoneOffset: Int
    var timeString: String { return Date(timeInterval: TimeInterval(timeZoneOffset),
                                         since: Date()).UTCTimeString
    }
    
    //NEEDS CITY NAME ADDED THROUGH GEOCODING
    
    let isCurrentLocation: Bool
    let doNotSave: Bool
    
    let current : Current
    let daily: [Daily]
    
    //5day forecast
    
    struct Current{
        
        let id: Int
        let main: String
        
        var isDay: Bool { return (dt>sunrise && dt<sunset) ? true : false }
        var isDayString: String { return isDay ? "day" : "night" }
        var conditionName: ConditionNames { return getConditionName(id) }
        var particle: String? { return getParticleName(id, isDay) }
        
        let dt: Int
        let sunrise: Int
        let sunset: Int
        let temp: Double
        
        var tempString: String{ return "\(String(format: "%.0f", temp))°" }
        
    }
    
    struct Daily{
        
        let id: Int
        let main: String
        let description: String
        
        var conditionName: ConditionNames { return getConditionName(id) }
        var conditionString: String {
            conditionName.rawValue
        }
        
        let dt: Int
        let sunrise: Int
        let sunset: Int
        let temp: Double
        let highTemp: Double
        let lowTemp: Double
        let cloudCover: Int
        let windSpeed: Double
        let windDirection: Double
        let precip: Double
        //let visibility: Double //this is in metres
        
        var dayString: String { return convertToDayString(dt) }
        var tempString: String { return "\(String(format: "%.0f", temp))°" }
        var highTempString: String { return "\(String(format: "%.0f", temp))°" }
        var lowTempString: String { return "\(String(format: "%.0f", temp))°" }
        var cloudCoverString: String { return "\(cloudCover)%" }
        var windSpeedString: String { return String(format: "%.1fM/S", Double(windSpeed)) }
        var windDirectionString: String { return windDirection.direction.description.uppercased() }
        var precipString: String { return "\(String(format: "%.0f", precip*100))%" }
        //var visibilityString: String { return String(format: "%.0fKM", Double(visibility/1000)) } //returns visibility string in KM
    }
    
}

//MARK: - Format date
func convertToDayString(_ dt: Int) -> String{
    
    let date = Date(timeIntervalSince1970: TimeInterval(dt))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "EEEE" //Specify your format that you want
    return dateFormatter.string(from: date)
    
}


//MARK: Condition Names Enum
enum ConditionNames: String{
    
    case broken_clouds, clear, few_clouds, mist, rain, rain_clouds, scattered_clouds, shower_rain, snow, thunderstorm
    
}

//MARK: Get Condiiton Name
func getConditionName(_ id: Int) -> ConditionNames{
    switch id{
        case 200...299:
            return .thunderstorm
        case 300...399:
            return .rain
        case 500...504:
            return .rain_clouds
        case 511:
            return .snow
        case 520...599:
            return .shower_rain
        case 600...699:
            return .snow
        case 700...780:
            return .mist
        case 781:
            return .thunderstorm
        case 800:
            return .clear
        case 801:
            return .few_clouds
        case 802...803:
            return .scattered_clouds
        case 804...804:
            return .broken_clouds
        default:
            return .scattered_clouds
    }
}
//MARK: Get Particle Name
func getParticleName(_ conditionID: Int, _ isDay: Bool) -> String? {
    switch getConditionName(conditionID){
        case .rain, .rain_clouds, .shower_rain:
            return C.particles.rainParticle
        case .thunderstorm:
            return C.particles.stormParticle
        case .snow:
            return C.particles.snowParticle
        case .clear, .few_clouds:
            return isDay ? nil : C.particles.starParticle
        case .scattered_clouds, .broken_clouds:
            return isDay ? nil : C.particles.starParticleCloudy
        default:
            return nil
    }
}


//MARK: - Wind direction calculation
enum Direction: String {
    case n, nne, ne, ene, e, ese, se, sse, s, ssw, sw, wsw, w, wnw, nw, nnw
}

extension Direction: CustomStringConvertible  {
    static let all: [Direction] = [.n, .nne, .ne, .ene, .e, .ese, .se, .sse, .s, .ssw, .sw, .wsw, .w, .wnw, .nw, .nnw]
    init(_ direction: Double) {
        let index = Int((direction + 11.25).truncatingRemainder(dividingBy: 360) / 22.5)
        self = Direction.all[index]
    }
    var description: String {
        return rawValue.uppercased()
    }
}

extension Double {
    var direction: Direction {
        return Direction(self)
    }
}

//MARK: - Dateformatter

extension Date {
    
    var UTCTimeString: String {
        
        //dateformatter for time thing
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "H:mm"
        
        return formatter.string(from: self)
        
    }
    
    
}

