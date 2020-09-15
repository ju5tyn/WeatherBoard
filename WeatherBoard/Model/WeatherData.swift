//
//  WeatherData.swift
//  Clima
//
//  Created by Justyn Henman on 27/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Decodable {
    
    let city: City
    let list: [List]
    
}

struct List: Decodable{
    
    let dt: Int
    let main: Main
    let weather: [Weather]
}

struct City: Decodable {
    
    let name: String
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

struct Main: Decodable {
    
    let temp: Double
    let feels_like: Double
}

struct Weather: Decodable {
    
    let id: Int
    let main: String
    let description: String
    
}
