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
    @IBOutlet weak var weatherContainerView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    
    
    //buttons
    @IBOutlet weak var menuButton: UIButton!
    
    //timetravel Buttons
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    @IBOutlet weak var dayAfterButton: UIButton!
    @IBOutlet weak var navButtons: UIStackView!
    
    //MARK: - Variables
    var daySelected: Int = 0
    var menuOpen: Bool = false
    
    var weatherModel: WeatherModel?
    let gradient = CAGradientLayer()
    let hillGradient = CAGradientLayer()
    var emitterNode = SKEmitterNode()
    
    //MARK: Realm
    let realm = try! Realm()
    var menuItems: Results<MenuItem>?
    
    //MARK: - Container views
    var weatherVC: WeatherViewController?
    var detailsVC: DetailsViewController?
    
    
    
    
    
    //MARK: - Delegate stuff
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //forces status bar to appear white
        overrideUserInterfaceStyle = .dark
        
        //setup for mask of hill
        let hillMask = UIImageView()
        hillMask.image = UIImage(named: "hills")
        hillMask.frame = hillView.bounds
        hillView.mask = hillMask

        //for gradients
        gradientSetup()
        highlightButton(todayButton)
        
        //drop shadows for uilabels
        todayButton.titleLabel?.textDropShadow()
        tomorrowButton.titleLabel?.textDropShadow()
        dayAfterButton.titleLabel?.textDropShadow()
        
        //delegate
        weatherManager.delegate = self
        locationManager.delegate = self
        
        detailsContainerView.isHidden = true
        
        //Requests user location
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
        clearDetails()
        
    }
    
    
    //MARK: - Buttons
    
    
    
    //MARK: Menu Pressed
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: C.segues.mainToMenu, sender: self)
        removeBlur()
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
        
        
        
        switch sender.titleLabel!.text{
            case "TODAY":
                daySelected = 0
                removeBlur()
            case "TOMORROW":
                daySelected = 1
                removeBlur()
            default:
                daySelected = 2
                addBlur()
                
        }
        
        if daySelected == 2{
            
            UIView.animate(withDuration: 0.3){ [self] in
                weatherContainerView.alpha = 0
                
                
                detailsContainerView.alpha = 1
            }
            
            
            weatherContainerView.isHidden = true
            detailsContainerView.isHidden = false
            
            
        }else{
            clearDetails()
            
            UIView.animate(withDuration: 0.3){ [self] in
                weatherContainerView.alpha = 1
                detailsContainerView.alpha = 0
            }
            
            
            weatherContainerView.isHidden = false
            detailsContainerView.isHidden = true
            setDetails()
            
        }
        
        
        
        
    }
    
//MARK: - Functions
    
    func blurSetup(){
        
            if !UIAccessibility.isReduceTransparencyEnabled {
                view.backgroundColor = .clear

                let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                let blurEffectView = UIVisualEffectView(effect: nil)
                blurEffectView.frame = self.view.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                let vibrancyView = UIVisualEffectView(effect: nil)
                vibrancyView.frame = self.view.bounds
                vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                blurEffectView.tag = 2
                
                view.insertSubview(blurEffectView, at: 2)
                blurEffectView.contentView.addSubview(vibrancyView)
                //blurEffectView.contentView.insertSubview(vibrancyView, aboveSubview: view.viewWithTag(2)!)
                
                UIView.animate(withDuration: 0.4){
                    blurEffectView.effect = blurEffect
                    vibrancyView.effect = vibrancyEffect
                }
                
                
                
            } else {
                view.backgroundColor = .clear
            }
        
    }
    
    func removeBlur(){
        if let blurView = view.viewWithTag(2) as? UIVisualEffectView{
            UIView.animate(withDuration: 0.3){
                blurView.effect = nil
            }
            
        }
    }
    
    func addBlur(){
        if daySelected == 2{
            if let blurView = view.viewWithTag(2) as? UIVisualEffectView{
                UIView.animate(withDuration: 0.3){
                    
                    blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                    
                }
                
            }else{
                blurSetup()
            }
        }
        
    }
    
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
        
        weatherVC?.clearWeatherDetails()
        detailsVC?.clearWeatherDetails()
        setGradientColor(color: "menu")
        removeParticles(from: view)
        navButtons.isHidden = true
        
    }
    
    //MARK: setDetails
    //sets weather details to contents of weathermodel
    func setDetails(){
        
        //if weather model has had contents populated
        if weatherModel != nil {
    
            navButtons.isHidden = false
            
            if (daySelected == 2){
                detailsVC?.setWeatherDetails(using: weatherModel!)
            }else{
                //sets weather containerView details
                weatherVC?.setWeatherDetails(using: weatherModel!, day: daySelected)
                detailsVC?.setWeatherDetails(using: weatherModel!)
            }
            
            
            //sets gradient color with string based on condition and day/night
            if daySelected == 2{
                if menuOpen == false {
                    self.setGradientColor(color: "\(weatherModel!.fiveDayArray[0].conditionName)_\(weatherModel!.isDayString)")
                }
            }else{
                if menuOpen == false {
                    self.setGradientColor(color: "\(weatherModel!.fiveDayArray[self.daySelected].conditionName)_\(weatherModel!.isDayString)")
                }
                if let particleToDisplay = weatherModel?.particleToDisplay[self.daySelected]{
                    emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                    setParticles(baseView: gradientView, emitterNode: emitterNode)
                
                }
            }

            //if particleToDisplay not nil, will set emitternode to particle
            
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
        
        gradient.colors = [
            UIColor(named: "grad_\(color)_bottom")!.cgColor,
            UIColor(named: "grad_\(color)_top")!.cgColor
        ]
        
        hillGradient.colors = [
            UIColor(named: "hill_\(color)_bottom")!.cgColor,
            UIColor(named: "hill_\(color)_top")!.cgColor
        ]
        
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
        if segue.identifier == C.segues.mainToMenu{
            
            //let menuVC = segue.destination as! MenuViewController
            
            //temp code to show particles permenantly
            //menuVC.particlesWereShown = true
            
        }else if segue.identifier == "mainToWeather"{
            
            weatherVC = segue.destination as? WeatherViewController
            
            
        }else if segue.identifier == "mainToDetails"{
            
            detailsVC = segue.destination as? DetailsViewController
            
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
            
            if self.weatherModel?.doNotSave != true{
                //writes the city name to realm
                do{
                    try self.realm.write{
                        
                        let newItem = MenuItem()
                        newItem.cityName = self.weatherModel?.cityName
                        newItem.isCurrentLocation = self.weatherModel!.isCurrentLocation
                        
                        
                        let colorName = "\(self.weatherModel!.fiveDayArray[0].conditionName)_\(self.weatherModel!.isDayString)"
                        newItem.topGradient = "button_\(colorName)_top"
                        newItem.bottomGradient = "button_\(colorName)_bottom"
                        
                        self.realm.add(newItem)
                    }
                }catch{
                    print(error)
                }
                //realm end
            }
            self.setDetails()
            
        }
    }
    
    func didFailWithError(error: Error){
        print(error)
        
        let failedAlert = UIAlertController(title: "Invalid Weather Location", message: "Please enter valid location", preferredStyle: .actionSheet)
        
        failedAlert.show(self, sender: self)
        print("error getting data")
        
        
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



