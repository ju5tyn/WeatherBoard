
/*
 import Foundation
 
 struct WeatherData: Decodable {
 
 let city: City
 let list: [List]
 
 }
 
 struct List: Decodable{
 
 let dt: Double
 let main: Main
 let weather: [Weather]
 let clouds: Clouds
 let wind: Wind
 let pop: Double
 let visibility: Double
 }
 
 struct Wind: Decodable{
 
 let speed: Double
 let deg: Double
 
 }
 
 struct Clouds: Decodable{
 
 let all: Int
 
 }
 
 struct City: Decodable {
 
 let name: String
 let timezone: Int
 let sunrise: Int
 let sunset: Int
 }
 
 struct Main: Decodable {
 
 let temp: Double
 let temp_min: Double
 let temp_max: Double
 
 }
 
 struct Weather: Decodable {
 
 let id: Int
 let main: String
 let description: String
 let icon: String
 }
 */
import Foundation

struct WeatherData: Decodable {
    
    let lat: Double
    let lon: Double
    
    let timezone_offset: Int
    
    let current: Current
    let daily: [Daily]
    
}

struct Current: Decodable {
    
    let weather: [Weather]
    
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    
}

struct Daily: Decodable{
    
    let weather: [Weather]
    
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Temp
    let clouds: Int
    let wind_speed: Double
    let wind_deg: Double
    let pop: Double
    //let visibility: Double
    
}

struct Temp: Decodable {
    
    let day: Double
    let min: Double
    let max: Double
    
}

struct Weather: Decodable {
    
    let id: Int
    let main: String
    let description: String
    let icon: String
}

