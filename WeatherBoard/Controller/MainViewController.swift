//
//  ViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/07/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import CoreLocation
import SpriteKit
import RealmSwift



class MainViewController: UIViewController{

    //MARK: - IBOutlets
    
    //views
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var hillView: UIView!
    
    //elements
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLocationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //buttons
    @IBOutlet weak var menuButton: UIButton!
    
    
    
    //timetravel Buttons
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    @IBOutlet weak var dayAfterButton: UIButton!

    
    
    
    //MARK: - Variables
    

    var daySelected: Int = 0
    var dayString: String = "day"
    var menuOpen: Bool = false
    
    var weatherModel: WeatherModel?
    let gradient = CAGradientLayer()
    let hillGradient = CAGradientLayer()
    var emitterNode = SKEmitterNode()
    
    //MARK: realm
    let realm = try! Realm()
    var menuItems: Results<MenuItem>?
    
    //MARK: - Delegate stuff
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        let hillMask = UIImageView()
        hillMask.image = UIImage(named: "hills")
        hillMask.frame = hillView.bounds
        hillView.mask = hillMask
        
        weatherManager.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        gradientSetup()
        highlightButton(todayButton)
        
        
        //drop shadows for uilabels
        tempLabel.textDropShadow()
        timeLocationLabel.textDropShadow()
        todayButton.titleLabel?.textDropShadow()
        tomorrowButton.titleLabel?.textDropShadow()
        dayAfterButton.titleLabel?.textDropShadow()
        
    }
    
    
    //MARK: - Buttons
    
    
    
    //MARK: Menu Pressed
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: Constants.segues.mainToMenu, sender: self)
        setGradientColor(color: "menu")
        hideParticles(view: view)
        mainView.isHidden = true
        menuOpen.toggle()
        
        
    }
    
    
    //MARK: Time Travel Pressed
    
    @IBAction func timeTravelButtonPressed(_ sender: UIButton) {
        
        //Highlights button that was pressed
        highlightButton(sender)
        //Clears details, changes day selection, then sets details
        clearDetails()
        switch sender.titleLabel!.text{
            case "TODAY":
                daySelected = 0
            case "TOMORROW":
                daySelected = 1
            default:
                daySelected = 2
        }
        setDetails()
        
    }
    
//MARK: - Functions
    
    
    //MARK: Set button alpha
    //Highlights currently selected button
    func highlightButton(_ buttonToHighlight: UIButton){
        todayButton.alpha = 0.5
        tomorrowButton.alpha = 0.5
        dayAfterButton.alpha = 0.5
        buttonToHighlight.alpha = 1
    }
    
    //MARK: Set button color UNUSED
    func setButtonColor(_ color: UIColor){
        todayButton.titleLabel!.textColor = color
        tomorrowButton.titleLabel!.textColor = color
        dayAfterButton.titleLabel!.textColor = color
        
    }
    
    
    //MARK: clearDetails
    //resets weather details to empty
    func clearDetails(){
        weatherImageView.image = nil
        tempLabel.text = ""
        timeLocationLabel.text = ""
        removeParticles(from: view)
    }
    
    //MARK: setDetails
    //sets weather details to contents of weathermodel
    func setDetails(){
        
        //removeParticles(from: gradientView)
        
        //if weather model has had contents populated
        if weatherModel != nil {
            
            //sets tempLabel label to temperature followed by condition
            self.tempLabel.text = "\(weatherModel!.tempString[self.daySelected])° \(weatherModel!.description[self.daySelected])"
            
            //sets time/location label to time in location followed by name of location
            self.timeLocationLabel.text = "\(weatherModel!.timeString) - \(weatherModel!.cityName)"
            
            //sets weather image to string based on condition and day/night
            self.weatherImageView.setImage(UIImage(named: "icon_\(weatherModel!.conditionName[self.daySelected])_\(weatherModel!.isDayString)"))
            
            //sets gradient color with string based on condition and day/night
            if menuOpen != true {
                self.setGradientColor(color: "\(weatherModel!.conditionName[self.daySelected])_\(weatherModel!.isDayString)")

            }
            
            //if particleToDisplay not nil, will set emitternode to particle
            if let particleToDisplay = weatherModel?.particleToDisplay[self.daySelected]{
                
                
                emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                setParticles(baseView: gradientView, emitterNode: emitterNode)
            
            }
            
            //stops animating activity indicator
            self.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: toggleHide
    //Hides all elements from current view
    //For when menu is opened
    func toggleHide() {
        mainView.isHidden = false
    }
    
    //MARK: setGradientColor
    //sets color of gradient to string passed in. Should match asset in asssets folder
    func setGradientColor(color: String){
        gradient.colors = [UIColor(named: "grad_\(color)_bottom")!.cgColor, UIColor(named: "grad_\(color)_top")!.cgColor]
        hillGradient.colors = [UIColor(named: "hill_\(color)_bottom")!.cgColor, UIColor(named: "hill_\(color)_top")!.cgColor]
        
    }
    
    //MARK: gradientSetup
    //sets gradient up for initial app launch. Should only be called on app launch
    func gradientSetup(){
    
        gradient.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height)*0.8)
        gradientView.layer.addSublayer(gradient)
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        
        hillGradient.frame = hillView.bounds
        hillView.layer.addSublayer(hillGradient)
        hillGradient.startPoint = CGPoint(x: 0.5, y: 1)
        hillGradient.endPoint = CGPoint(x: 0.5, y: 0)
        
        setGradientColor(color: "menu")
        
    }
    

    
    
    //MARK: - Segues
    //Called on segue to menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.mainToMenu{
            
            //let menuVC = segue.destination as! MenuViewController
            
            //temp code to show particles permenantly
            //menuVC.particlesWereShown = true
            
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    

}


//MARK: - Location Manager

extension MainViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        
        if let location = locations.last{
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            weatherManager.fetchWeather(latitude: lat, longitude: lon, time: daySelected)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
        print(error)
    }
    
}

//MARK: - WeatherManagerDelegate

extension MainViewController: WeatherManagerDelegate{
   
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        
        weatherModel = weather
        //sets this view's weather model to data from weathermanager
        
        
        
        
        DispatchQueue.main.async {
            
            do{
                try self.realm.write{
                    let newItem = MenuItem()
                    newItem.cityName = self.weatherModel?.cityName
                    self.realm.add(newItem)
                }
            }catch{
                print(error)
            }
            
            self.dayString = weather.isDay ? "day" : "night"
            self.setDetails()
            
        }
    }
    
    func didFailWithError(error: Error){
        print(error)
        print("error getting data")
        
        
    }
}


//MARK: - EXT ImageView


extension UIImageView{
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.4 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionFlipFromRight, animations: {
            
            self.image = image
        }, completion: nil)
    }
}

//MARK: - EXT Label

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.5
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}



