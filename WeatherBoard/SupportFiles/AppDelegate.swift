//
//  AppDelegate.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/07/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: Realm
    let realm = try! Realm()
    var menuItems: Results<MenuItem>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Google admob setup
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "894eac13dde30d727b53a35d27b7850e" ];
        
        if (UserDefaults.standard.integer(forKey: C.defaults.defaultToGPS) == 0){
            do{
                try realm.write{
                    let oldLocations = realm.objects(MenuItem.self).filter("isCurrentLocation == %@", true)
                    realm.delete(oldLocations)
                }
            }catch{
                print(error)
            }
        }
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
 
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
        do{
            try realm.write{
                let oldLocations = realm.objects(MenuItem.self).filter("isCurrentLocation == %@", true)
                realm.delete(oldLocations)
            }
        }catch{
            print(error)
        }
    }


}

