//
//  weatherManager.swift
//  Clima
//
//  Created by Justyn Henman on 10/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}



struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "\(C.mainURL)\(Keys.openweathermap)"
    
    //MARK: Fetch Weather
    
    func fetchWeather(cityName: String, time: Int, doNotSave: Bool) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        performRequest(with: urlString, time: time, isCurrentLocation: false, doNotSave: doNotSave)
        
    }
    
    func fetchWeather(latitude: Double, longitude: Double, time: Int){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        performRequest(with: urlString, time: time, isCurrentLocation: true, doNotSave: false)
    }
    
    
    func performRequest(with urlString: String, time: Int, isCurrentLocation: Bool, doNotSave: Bool) {
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
            
            //attributes today
            //weather[0] is only in array
            //change list array number to count in 3 hour increments
            let id = [decodedData.list[0].weather[0].id,
                      decodedData.list[7].weather[0].id]
            
            let temp = [decodedData.list[0].main.temp, decodedData.list[7].main.temp]
            
            let description = [decodedData.list[0].weather[0].main, decodedData.list[7].weather[0].main]
            
            let fiveDayArray = [WeatherModel.fiveDay(conditionID: decodedData.list[0].weather[0].id,
                                               description: decodedData.list[0].weather[0].main,
                                               temp: decodedData.list[0].main.temp,
                                               highTemp: decodedData.list[0].main.temp_max,
                                               lowTemp: decodedData.list[0].main.temp_min,
                                               cloudCover: decodedData.list[0].clouds.all,
                                               windSpeed: decodedData.list[0].wind.speed,
                                               windDirection: decodedData.list[0].wind.deg,
                                               precip: decodedData.list[0].pop,
                                               visibility: decodedData.list[0].visibility),
                           
                           WeatherModel.fiveDay(conditionID: decodedData.list[8].weather[0].id,
                                                description: decodedData.list[8].weather[0].main,
                                                temp: decodedData.list[8].main.temp,
                                                highTemp: decodedData.list[8].main.temp_max,
                                                lowTemp: decodedData.list[8].main.temp_min,
                                                cloudCover: decodedData.list[8].clouds.all,
                                                windSpeed: decodedData.list[8].wind.speed,
                                                windDirection: decodedData.list[8].wind.deg,
                                                precip: decodedData.list[8].pop,
                                                visibility: decodedData.list[8].visibility),
                           
                           WeatherModel.fiveDay(conditionID: decodedData.list[16].weather[0].id,
                                                description: decodedData.list[16].weather[0].main,
                                                temp: decodedData.list[16].main.temp,
                                                highTemp: decodedData.list[16].main.temp_max,
                                                lowTemp: decodedData.list[16].main.temp_min,
                                                cloudCover: decodedData.list[16].clouds.all,
                                                windSpeed: decodedData.list[16].wind.speed,
                                                windDirection: decodedData.list[16].wind.deg,
                                                precip: decodedData.list[16].pop,
                                                visibility: decodedData.list[16].visibility),
                           
                           WeatherModel.fiveDay(conditionID: decodedData.list[24].weather[0].id,
                                                description: decodedData.list[24].weather[0].main,
                                                temp: decodedData.list[24].main.temp,
                                                highTemp: decodedData.list[24].main.temp_max,
                                                lowTemp: decodedData.list[24].main.temp_min,
                                                cloudCover: decodedData.list[24].clouds.all,
                                                windSpeed: decodedData.list[24].wind.speed,
                                                windDirection: decodedData.list[24].wind.deg,
                                                precip: decodedData.list[24].pop,
                                                visibility: decodedData.list[24].visibility),
                           
                           WeatherModel.fiveDay(conditionID: decodedData.list[32].weather[0].id,
                                                description: decodedData.list[32].weather[0].main,
                                                temp: decodedData.list[32].main.temp,
                                                highTemp: decodedData.list[32].main.temp_max,
                                                lowTemp: decodedData.list[32].main.temp_min,
                                                cloudCover: decodedData.list[32].clouds.all,
                                                windSpeed: decodedData.list[32].wind.speed,
                                                windDirection: decodedData.list[32].wind.deg,
                                                precip: decodedData.list[32].pop,
                                                visibility: decodedData.list[32].visibility)
            ]
            //returns weather model to the caller
            return WeatherModel(timeZone: timezone, cityName: cityName, sunrise: sunrise, sunset: sunset,  dt: dt, isCurrentLocation: isCurrentLocation, doNotSave: doNotSave, conditionID: id, temperature: temp, description: description, fiveDayArray: fiveDayArray)
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
            
    }
    
}


