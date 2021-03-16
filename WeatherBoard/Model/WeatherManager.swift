//
//  weatherManager.swift
//  Clima
//
//  Created by Justyn Henman on 10/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}




struct WeatherManager {
    
    
    var delegate: WeatherManagerDelegate?
    
    
    //MARK: Fetch Weather
    
    func getUnits() -> String{
        
        let defaults = UserDefaults.standard

        switch defaults.integer(forKey: C.defaults.units){
            case 0:
                return C.units.metric
            case 1:
                return C.units.imperial
            default:
                return C.units.metric
        }
    }
    
    
    func fetchWeather(cityName: String, doNotSave: Bool){
        
        let weatherURL = "\(C.mainURL)\(Keys.openweathermap)\(getUnits())"

        //converts search to lat+lon
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            
            let placemark = placemarks?.first
            if let lat = placemark?.location?.coordinate.latitude, let lon = placemark?.location?.coordinate.longitude {
                let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
                print(urlString)
                performRequest(with: urlString, isCurrentLocation: false, doNotSave: doNotSave)
                
            }else{
                if let e = error{
                    print(e.localizedDescription)
                    self.delegate?.didFailWithError(error: e)
                }
                
            }
            
        }
        
    }
    
    func fetchWeather(latitude: Double, longitude: Double){
        
        let weatherURL = "\(C.mainURL)\(Keys.openweathermap)\(getUnits())"
        
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        print("Location Granted 📍")
        performRequest(with: urlString, isCurrentLocation: true, doNotSave: false)
    }
    
    
    func performRequest(with urlString: String, isCurrentLocation: Bool, doNotSave: Bool) {
        //Create a url
        
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {
                
                (data, response, error) in
                
                if error != nil{
                    //print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData, isCurrentLocation: isCurrentLocation, doNotSave: doNotSave) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
            
        }
        
    }
    


    func parseJSON(_ data: Data, isCurrentLocation: Bool, doNotSave: Bool) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            
            return WeatherModel(lat: decodedData.lat,
                                lon: decodedData.lon,
                                timeZoneOffset: decodedData.timezone_offset,
                                isCurrentLocation: isCurrentLocation,
                                doNotSave: doNotSave,
                                current: getCurrent(decodedData),
                                daily: getDailyArray(decodedData),
                                hourly: getHourlyArray(decodedData)
            )
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    

    
    //current day data
    
    func getCurrent(_ decodedData: WeatherData) -> WeatherModel.Current{
        
        let data = decodedData.current
        
        return WeatherModel.Current(id: data.weather[0].id,
                                    main: data.weather[0].main,
                                    dt: data.dt,
                                    sunrise: data.sunrise,
                                    sunset: data.sunset,
                                    temp: data.temp
        )
    }
    
    //5 day forecast array
    
    func getHourlyArray(_ decodedData: WeatherData) -> [WeatherModel.Hourly]{
        var array: [WeatherModel.Hourly] = []
        for hour in 0...12{ array.append(getHourly(decodedData, hour))}
        return array
        
    }
    
    func getHourly(_ decodedData: WeatherData, _ hour: Int) -> WeatherModel.Hourly {
        
        let hourData = decodedData.hourly[hour]
        
        return WeatherModel.Hourly(id: hourData.weather[0].id,
                                   main: hourData.weather[0].main,
                                   description: hourData.weather[0].description,
                                   currentDt: decodedData.current.dt,
                                   dt: hourData.dt,
                                   sunrise: decodedData.current.sunrise,
                                   sunset: decodedData.current.sunset,
                                   temp: hourData.temp,
                                   rain: hourData.rain?.value,
                                   clouds: hourData.clouds
        )
        
        
        
    }
    
    
    func getDailyArray(_ decodedData: WeatherData) -> [WeatherModel.Daily]{
        var array: [WeatherModel.Daily] = []
        for day in 0...4{ array.append(getDaily(decodedData, day)) }
        return array
    }
    
    
    func getDaily(_ decodedData: WeatherData, _ day: Int) -> WeatherModel.Daily{
        
        let dailyData = decodedData.daily[day]
        
        
        
        return WeatherModel.Daily(id: dailyData.weather[0].id,
                                  main: dailyData.weather[0].main,
                                  description: dailyData.weather[0].description,
                                  currentDt: decodedData.current.dt,
                                  dt: dailyData.dt,
                                  sunrise: decodedData.current.sunrise,
                                  sunset: decodedData.current.sunset,
                                  temp: dailyData.temp.day,
                                  highTemp: dailyData.temp.max,
                                  lowTemp: dailyData.temp.min,
                                  cloudCover: dailyData.clouds,
                                  windSpeed: dailyData.wind_speed,
                                  windDirection: dailyData.wind_deg,
                                  precip: dailyData.pop
                                  //visibility: data.visibility
        )
        
    }
    
    
    
    
    
}


