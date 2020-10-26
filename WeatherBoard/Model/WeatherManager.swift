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
    
    let weatherURL = "\(C.mainURL)\(Keys.openweathermap)"
    
    //MARK: Fetch Weather
    
    func fetchWeather(cityName: String, doNotSave: Bool) {
        
        //converts search to lat+lon
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            
            let placemark = placemarks?.first
            if let lat = placemark?.location?.coordinate.latitude, let lon = placemark?.location?.coordinate.longitude {
                let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
                performRequest(with: urlString, isCurrentLocation: false, doNotSave: doNotSave)
            
            }else{
                
                //protection for if search fails. Might replace with a wrong location warning 
                let urlString = "\(weatherURL)&q=\(cityName)"
                performRequest(with: urlString, isCurrentLocation: false, doNotSave: doNotSave)
                
                
            }
            
        }
  
    }
    
    func fetchWeather(latitude: Double, longitude: Double){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        print("ios gave locaiton")
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
            
            //global attributes
            let timezone = decodedData.city.timezone
            let cityName = decodedData.city.name
            //sunset/sunrise and dt times don't change much, so made global
            let sunset = decodedData.city.sunset
            let sunrise = decodedData.city.sunrise
            let dt = decodedData.list[0].dt
            let id = [decodedData.list[0].weather[0].id,
                      decodedData.list[8].weather[0].id]
            
            //attributes today
            //weather[0] is only in array
            let fiveDayArray = [getDay(decodedData: decodedData, timeNumber: 0),
                                getDay(decodedData: decodedData, timeNumber: 8),
                                getDay(decodedData: decodedData, timeNumber: 16),
                                getDay(decodedData: decodedData, timeNumber: 24),
                                getDay(decodedData: decodedData, timeNumber: 32)
            ]
            //returns weather model to the caller
            return WeatherModel(timeZone: timezone,
                                cityName: cityName,
                                sunrise: sunrise,
                                sunset: sunset,
                                dt: dt,
                                isCurrentLocation: isCurrentLocation,
                                doNotSave: doNotSave,
                                conditionID: id,
                                fiveDayArray: fiveDayArray)
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
            
        
        
    }
    
    func getDay(decodedData: WeatherData, timeNumber: Int) -> WeatherModel.fiveDay{
        
        return WeatherModel.fiveDay(conditionID: decodedData.list[timeNumber].weather[0].id,
                                    dt: decodedData.list[timeNumber].dt,
                                    description: decodedData.list[timeNumber].weather[0].main,
                                    temp: decodedData.list[timeNumber].main.temp,
                                    highTemp: decodedData.list[timeNumber].main.temp_max,
                                    lowTemp: decodedData.list[timeNumber].main.temp_min,
                                    cloudCover: decodedData.list[timeNumber].clouds.all,
                                    windSpeed: decodedData.list[timeNumber].wind.speed,
                                    windDirection: decodedData.list[timeNumber].wind.deg,
                                    precip: decodedData.list[timeNumber].pop,
                                    visibility: decodedData.list[timeNumber].visibility)
        
        
    }
    
}


