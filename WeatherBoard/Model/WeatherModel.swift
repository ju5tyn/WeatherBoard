
import Foundation
import CoreLocation

struct WeatherModel{
    
    //MARK: - Data
    
    let lat: Double
    let lon: Double
    let timeZoneOffset: Int
    var timeString: String { return Date(timeInterval: TimeInterval(timeZoneOffset),
                                         since: Date()).UTCTimeString
    }
    let isCurrentLocation: Bool
    let doNotSave: Bool
    
    let current: Current
    let minutely: [Minutely]?
    let daily: [Daily]
    let hourly: [Hourly]
    
    var rainInfo: RainInfo? {return getRain(weatherModelMinutely: minutely)}
    
    var locationName: String? = ""
    
    //MARK: Current
    
    struct RainInfo{
        enum Types{
            case starting, stopping, wholeHour
        }
        var type: Types
        var minutes: Int?
        
    }
    
    
    
    struct Current{
        
        
        
        let id: Int
        let main: String
        
        var isDay: Bool { return (dt>sunrise && dt<sunset) ? true : false }
        var isDayString: String { return isDay ? "day" : "night" }
        var conditionName: ConditionNames { return getConditionName(id) }
        var particle: String? { return getParticleName(id, isDay) }
        var fullName: String? { return getFullName(id, isDay) }
        
        let dt: Int
        let sunrise: Int
        let sunset: Int
        let temp: Double
        
        var tempString: String{ return "\(String(format: "%.0f", temp))°" }
        
        var isSunset: Bool {
            let sunsetRange = (sunset-2000)...(sunset+2000)
            return (sunsetRange.contains(dt) && ((conditionName == .clear) || conditionName == .few_clouds || conditionName == .scattered_clouds)) ? true : false
        }
        
        var isSunrise: Bool {
            let sunriseRange = (sunrise-2000)...(sunrise+2000)
            return (sunriseRange.contains(dt) && ((conditionName == .clear) || conditionName == .few_clouds || conditionName == .scattered_clouds)) ? true : false
        }
        
        
        
    }
    
    struct Minutely{

        let dt: Int
        let precip: Double

    }
    
    struct Hourly{
        
        let id: Int
        let main: String
        let description: String
        let currentDt: Int // date time for now
        let dt: Int // date time for this day
        let sunrise: Int
        let sunset: Int
        let temp: Double
        
        var tempString: String{ return "\(String(format: "%.0f", temp))°" }
        var isDay: Bool { return (dt>sunrise && dt<sunset) ? true : false }
        var isDayString: String { return isDay ? "day" : "night" }
        var conditionName: ConditionNames { return getConditionName(id) }
        var particle: String? { return getParticleName(id, isDay) }
        
        let rain: Double?
        let clouds: Int


    }
    
    //MARK: Daily
    
    struct Daily{
        
        let id: Int
        let main: String
        let description: String
        
        var isDay: Bool { return (currentDt>sunrise && currentDt<sunset) ? true : false }
        var particle: String? { return getParticleName(id, isDay) }
        
        var conditionName: ConditionNames { return getConditionName(id) }
        var conditionString: String { conditionName.rawValue }
        var fullName: String? { return getFullName(id, isDay) }
        var smallName: String? { return getSmallName(id, isDay)}
        
        let currentDt: Int // date time for now
        let dt: Int // date time for this day
        let sunrise: Int
        let sunset: Int
        let temp: Double
        let highTemp: Double
        let lowTemp: Double
        let cloudCover: Int
        let windSpeed: Double
        let windDirection: Double
        let precip: Double
        
        //let visibility: Double //this is in meters
        
        var dayString: String { return convertToDayString(dt) }
        var tempString: String { return "\(String(format: "%.0f", temp))°" }
        var highTempString: String { return "\(String(format: "%.0f", highTemp))°" }
        var lowTempString: String { return "\(String(format: "%.0f", lowTemp))°" }
        var cloudCoverString: String { return "\(cloudCover)%" }
        var windSpeedString: String { return String(format: "%.1fM/S", Double(windSpeed)) }
        var windDirectionString: String { return windDirection.direction.description.uppercased() }
        var precipString: String { return "\(String(format: "%.0f", precip*100))%" }
        //var visibilityString: String { return String(format: "%.0fKM", Double(visibility/1000)) } //returns visibility string in KM
    }
    
    
    
    
    func getRain(weatherModelMinutely: [WeatherModel.Minutely]?) -> RainInfo? {
        
        if weatherModelMinutely != nil {
            var startDt: Int?
            var stopDt: Int?
            let nowDt: Int = weatherModelMinutely![0].dt
            
            if weatherModelMinutely![0].precip != 0{
                //raining right now
                for minute in weatherModelMinutely!{
                    if minute.precip == 0{
                        stopDt = minute.dt
                        //get time interval between nowDt and stopDt
                        let interval = stopDt! - nowDt
                        let intervalInMinutes = ((interval)/60)
                        print("Rain stopping in \(intervalInMinutes) minutes" )
                        return RainInfo(type: .stopping, minutes: intervalInMinutes)
                    }
                }
                if stopDt == nil{
                    print("rain for whole hour")
                    return RainInfo(type: .wholeHour)
                    //rain for whole hour
                }
            }else{
                //check to see if rain in rest of hour
                for minute in weatherModelMinutely!{
                    if minute.precip > 0{
                        startDt = minute.dt
                        //get time interval between nowDt and startDt
                        let interval = startDt! - nowDt
                        let intervalInMinutes = ((interval)/60)
                        print("Rain starting in \(intervalInMinutes) minutes" )
                        return RainInfo(type: .starting, minutes: intervalInMinutes)
                    }
                }
                if startDt == nil{
                    print("no rain for the hour")
                    return nil
                    //no rain for the hour
                }
            }
        }
        //for minute in weatherModel.
        
        //on nothing occuring
        return nil
    }
    
}
//MARK: - Functions



//MARK:  Format date
func convertToDayString(_ dt: Int) -> String{
    
    let date = Date(timeIntervalSince1970: TimeInterval(dt))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "EEEE" //Specify your format that you want
    
    //print(dateFormatter.string(from: date))
    
    return dateFormatter.string(from: date)
    
}


//MARK: Condition Names Enum
enum ConditionNames: String{
    
    case broken_clouds, clear, few_clouds, mist, rain, rain_clouds, scattered_clouds, shower_rain, snow, thunderstorm
    
}




//MARK: Get Condition Name
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


//MARK: Get Full Condition name
func getFullName(_ conditionID: Int, _ isDay: Bool) -> String? {
    switch getConditionName(conditionID){
        case .thunderstorm:
            return NSLocalizedString("FULL_NAME_STORM", comment: "Storm label")
        case .rain:
            return NSLocalizedString("FULL_NAME_DRIZZLE", comment: "Drizzle")
        case .rain_clouds:
            return NSLocalizedString("FULL_NAME_RAIN", comment: "Rain")
        case .shower_rain:
            return NSLocalizedString("FULL_NAME_SHOWER_RAIN", comment: "Shower rain")
        case .snow:
            return NSLocalizedString("FULL_NAME_SNOW", comment: "Snow")
        case .mist:
            return NSLocalizedString("FULL_NAME_MIST", comment: "Mist")
        case .clear:
            return NSLocalizedString("FULL_NAME_CLEAR", comment: "Clear")
        case .few_clouds:
            return NSLocalizedString("FULL_NAME_FEW_CLOUDS", comment: "Few clouds")
        case .scattered_clouds:
            return NSLocalizedString("FULL_NAME_SCATTERED_CLOUDS", comment: "Scattered clouds")
        case .broken_clouds:
            return NSLocalizedString("FULL_NAME_BROKEN_CLOUDS", comment: "Broken clouds")
    }
}


//MARK: Get Smaller Condition name
func getSmallName(_ conditionID: Int, _ isDay: Bool) -> String? {
    switch getConditionName(conditionID){
        case .thunderstorm:
            return NSLocalizedString("SHORT_NAME_STORM", comment: "Storm label")
        case .rain:
            return NSLocalizedString("SHORT_NAME_DRIZZLE", comment: "Drizzle")
        case .rain_clouds:
            return NSLocalizedString("SHORT_NAME_RAIN", comment: "Rain")
        case .shower_rain:
            return NSLocalizedString("SHORT_NAME_SHOWER_RAIN", comment: "Shower rain")
        case .snow:
            return NSLocalizedString("SHORT_NAME_SNOW", comment: "Snow")
        case .mist:
            return NSLocalizedString("SHORT_NAME_MIST", comment: "Mist")
        case .clear:
            return NSLocalizedString("SHORT_NAME_CLEAR", comment: "Clear")
        case .few_clouds:
            return NSLocalizedString("SHORT_NAME_FEW_CLOUDS", comment: "Few clouds")
        case .scattered_clouds:
            return NSLocalizedString("SHORT_NAME_SCATTERED_CLOUDS", comment: "Scattered clouds")
        case .broken_clouds:
            return NSLocalizedString("SHORT_NAME_BROKEN_CLOUDS", comment: "Broken clouds")
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
            return isDay ? nil : C.particles.starParticle
        default:
            return nil
    }
}


//MARK:  Calculate wind direction
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

//MARK:  Format date as time

extension Date {
    
    var UTCTimeString: String {
        
        //dateformatter for time thing
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "H:mm"
        
        return formatter.string(from: self)
        
    }
    
    
}

extension Int {
    func getDateStringFromUnixTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        return dateFormatter.string(from: Date(timeIntervalSinceNow: TimeInterval(self)))
    }
}

