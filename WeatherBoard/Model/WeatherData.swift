import Foundation

struct WeatherData: Decodable {
    
    let lat: Double
    let lon: Double
    
    let timezone_offset: Int
    
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
    
}


struct Hourly: Decodable {
    
    let dt: Int
    let temp: Double
    let clouds: Int
    
    let weather: [Weather]
    
    let pop: Double
    let rain: Rain?
    
}



struct Rain: Decodable{
    
    let value: Double
    private enum CodingKeys: String, CodingKey { case value = "1h"} //since owa object name contains int, add here
    
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

