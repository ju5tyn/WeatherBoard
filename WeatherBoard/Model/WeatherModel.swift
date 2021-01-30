
import Foundation
import CoreLocation

struct WeatherModel{
    
    let lat: Double
    let lon: Double
    
    //backup location name
    //var typedName: String

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
        
        var isDay: Bool { return (dt>sunrise && dt<sunset) ? true : false }
        
        var particle: String? { return getParticleName(id, isDay) }
        
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

