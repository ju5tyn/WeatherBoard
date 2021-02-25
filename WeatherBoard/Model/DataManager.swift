//
//  DataManager.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 21/02/2021.
//  Copyright © 2021 Justyn Henman. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

struct DataManager {
    
    func saveWeatherModel(_ model: WeatherModel){
        
        let realm = try! Realm()
        
        if model.doNotSave != true{

            //writes the city name to realm
            
            
            let location = CLLocation(latitude: model.lat, longitude: model.lon)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                
                realm.beginWrite()

                
                let newItem = MenuItem()
                newItem.isCurrentLocation = model.isCurrentLocation
                
                var colorName = "menu"
                
                if (model.current.isSunset){
                    colorName = "sunset"
                } else if (model.current.isSunrise){
                    colorName = "sunrise"
                }else{
                    colorName = "\(model.current.conditionName)_\(model.current.isDayString)"
                }

                newItem.topGradient = "button_\(colorName)_top"
                newItem.bottomGradient = "button_\(colorName)_bottom"
                
                newItem.cityName = placemarks?.first?.country
                newItem.cityName = placemarks?.first?.locality // will default to country if none supplied

                // USERDEFAULTS
                let defaults = UserDefaults.standard
                defaults.setValue(newItem.cityName, forKey: C.defaults.defaultLocation)
                // ============

                realm.add(newItem)
                
                do{
                    try realm.commitWrite()
                } catch {
                    print(error)
                }
            })
            
            
            //realm end
        }
        
        
    }
    
    
}
