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
    
    let weatherURL = "\(Constants.mainURL)\(Keys.openweathermap)"
    
    //MARK: Fetch Weather
    
    func fetchWeather(cityName: String, time: Int) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString, time: time, isCurrentLocation: false)
        
    }
    
    func fetchWeather(latitude: Double, longitude: Double, time: Int){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString, time: time, isCurrentLocation: true)
    }
    
    
    func performRequest(with urlString: String, time: Int, isCurrentLocation: Bool) {
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
                        if let weather = self.parseJSON(safeData, isCurrentLocation: isCurrentLocation) {
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
            }
            
            task.resume()
            
        }
        
    }
    
    func parseJSON(_ data: Data, isCurrentLocation: Bool) -> WeatherModel? {
        
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
            let id = [decodedData.list[0].weather[0].id,decodedData.list[7].weather[0].id,decodedData.list[15].weather[0].id]
            
            let temp = [decodedData.list[0].main.temp, decodedData.list[7].main.temp, decodedData.list[15].main.temp]
            
            let description = [decodedData.list[0].weather[0].main, decodedData.list[7].weather[0].main, decodedData.list[15].weather[0].main]
            
            
            //returns weather model to the caller
            return WeatherModel(timeZone: timezone, cityName: cityName, sunrise: sunrise, sunset: sunset,  dt: dt, isCurrentLocation: isCurrentLocation, conditionID: id, temperature: temp, description: description)
            
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
            
    }
    
}


