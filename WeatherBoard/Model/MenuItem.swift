//
//  MenuItem.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 26/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import Foundation
import RealmSwift

class MenuItem: Object{
    
    @objc dynamic var cityName: String?
    @objc dynamic var date: Date = Date()
    @objc dynamic var isCurrentLocation: Bool = false
    
}
