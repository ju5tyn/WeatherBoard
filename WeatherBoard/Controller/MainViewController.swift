//
//  ViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/07/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import Hex
import CoreLocation
import SpriteKit



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
    let emitterNode = SKEmitterNode(fileNamed: Constants.particles.rainParticle)!
    
    
    
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
        setButton(todayButton)
        
        setParticles(baseView: gradientView, emitterNode: emitterNode)
    }
    
    
    
    
    //MARK: - Buttons
    
    
    
    //MARK: Menu Pressed
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: Constants.segues.mainToMenu, sender: self)
        
        setGradientColor(color: "menu")
        mainView.isHidden = true
        menuOpen.toggle()
        hideParticles(view: view)
        
        
    }
    
    
    //MARK: Time Travel Pressed
    
    @IBAction func timeTravelButtonPressed(_ sender: UIButton) {
        
        //Sets current button clicked to highlighted
        setButton(sender)
        sender.isHighlighted = false
        
        if weatherModel != nil{
            if (weatherModel!.conditionName[self.daySelected] == "clear"){
                setButtonColor(UIColor.white)
            }else{
                setButtonColor(UIColor.white)
            }
        }
        
        //Clears details, changes day selection, then sets details
        resetDetails()
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
    
    
    
    //MARK: - setButton
    //resets all button appearance to transparent
    func setButton(_ buttonToHighlight: UIButton){
        
        todayButton.alpha = 0.5
        tomorrowButton.alpha = 0.5
        dayAfterButton.alpha = 0.5
        buttonToHighlight.alpha = 1
        
        
    }
    
    func setButtonColor(_ color: UIColor){
        todayButton.titleLabel!.textColor = color
        tomorrowButton.titleLabel!.textColor = color
        dayAfterButton.titleLabel!.textColor = color
        
    }
    
    //MARK: - resetDetails
    //resets weather details to empty
    func resetDetails(){
        weatherImageView.image = nil
        tempLabel.text = ""
        timeLocationLabel.text = ""
    }
    
    //MARK: setDetails
    //sets weather details to contents of weathermodel
    func setDetails(){
        //if weather model has had contents populated
        if weatherModel != nil {
            
            //sets tempLabel label to temperature followed by condition
            self.tempLabel.text = "\(weatherModel!.tempString[self.daySelected])° \(weatherModel!.description[self.daySelected])"
            
            //sets time/location label to time in location followed by name of location
            self.timeLocationLabel.text = "\(weatherModel!.timeString) - \(weatherModel!.cityName)"
            
            //sets weather image to string based on condition and day/night
            self.weatherImageView.image = UIImage(named: "icon_\(weatherModel!.conditionName[self.daySelected])_\(weatherModel!.isDayString)")
            
            //sets gradient color with string based on condition and day/night
            if menuOpen != true {
                self.setGradientColor(color: "\(weatherModel!.conditionName[self.daySelected])_\(weatherModel!.isDayString)")
            
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
            
            let menuVC = segue.destination as! MenuViewController
            print(menuVC)
            
            //temp code to show particles permenantly
            menuVC.particlesWereShown = true
            
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
        print("Location Error")
    }
    
}

//MARK: - WeatherManagerDelegate

extension MainViewController: WeatherManagerDelegate{
   
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        
        weatherModel = weather
        //sets this view's weather model to data from weathermanager
        
        DispatchQueue.main.async {
            
            if weather.isDay{
                self.dayString = "day"
            }else{
                self.dayString = "night"
            }

            self.setDetails()
            
            
        }
        
         
    }
    
    func didFailWithError(error: Error){
        print(error)
        
        DispatchQueue.main.async{
            
            print(error)
            
        }
    }
}





