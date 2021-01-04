import UIKit
import CoreLocation
import SpriteKit
import RealmSwift

class MainViewController: UIViewController{
    

    //MARK: - OUTLETS
    
    //views
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var hillView: UIView!
    @IBOutlet weak var weatherContainerView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!

    //buttons
    @IBOutlet weak var menuButton: UIButton!
    
    //nav Buttons
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    @IBOutlet weak var dayAfterButton: UIButton!
    @IBOutlet weak var navButtons: UIStackView!
    
    

    
    //MARK: - VARIABLES
    
    
    
    var daySelected: Int = 0
    var menuOpen: Bool = false
    
    var weatherModel: WeatherModel?
    let gradient = CAGradientLayer()
    let hillGradient = CAGradientLayer()
    var emitterNode = SKEmitterNode()
    
    //Realm
    let realm = try! Realm()
    var menuItems: Results<MenuItem>?
    
    //Container views
    var weatherVC: WeatherViewController?
    var detailsVC: DetailsViewController?
    
    //Delegate stuff
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    
    
    
    
    
    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
 
        overrideUserInterfaceStyle = .dark
        weatherManager.delegate = self
        locationManager.delegate = self
        detailsContainerView.isHidden = true
        
        addHill()
        addGradient()
        addTextShadow()
        highlightButton(todayButton)
        getLocation()
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
                updateBlur()
        }
        
        daySelected == 2 ?
            viewChange(hide: weatherContainerView, show: detailsContainerView, refresh: false)
            :
            viewChange(hide: detailsContainerView, show: weatherContainerView, refresh: true)
        
    }
    
    func viewChange(hide viewToHide: UIView, show viewToShow: UIView, refresh: Bool){
        
        UIView.animate(withDuration: 0.3){
            viewToShow.alpha = 1
            viewToHide.alpha = 0
        }
        viewToShow.isHidden = false
        viewToHide.isHidden = true
        refresh ? setDetails() : nil
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
//MARK: - FUNCTIONS
    
    func getLocation(){
        //Requests user location
                locationManager.requestWhenInUseAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                locationManager.requestLocation()
    }
    
 
 
    //MARK: clearDetails
    //resets weather details to empty
    func clearDetails(){
        weatherVC?.clearWeatherDetails()
        detailsVC?.clearWeatherDetails()
        setGradientColor(color: "menu")
        removeParticles(from: gradientView)
        navButtons.isHidden = true
    }
    
    //MARK: setDetails
    //sets weather details to contents of weathermodel
    func setDetails(){
        //if weather model has had contents populated
        if weatherModel != nil {
            
            navButtons.isHidden = false
            
            weatherVC?.setWeatherDetails(using: weatherModel!, day: daySelected)
            detailsVC?.setWeatherDetails(using: weatherModel!)
            
            
            
            //sets gradient color with string based on condition and day/night
            if daySelected == 2{
                if menuOpen == false {
                    self.setGradientColor(color: "\(weatherModel!.daily[1].conditionName)_\(weatherModel!.current.isDayString)")
                }
            }else{
                if menuOpen == false {
                    
                    if self.daySelected == 0 {
                        self.setGradientColor(color: "\(weatherModel!.current.conditionName)_\(weatherModel!.current.isDayString)")
                    }else{
                        self.setGradientColor(color: "\(weatherModel!.daily[1].conditionName)_\(weatherModel!.current.isDayString)")
                    }
                    
                    
                }
                
                if self.daySelected == 0{
                    if let particleToDisplay = weatherModel?.current.particle{
                        emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                        removeParticles(from: gradientView)
                        setParticles(baseView: gradientView, emitterNode: emitterNode)
                    
                    }
                }else {
                    if let particleToDisplay = weatherModel?.current.particle{
                        emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                        removeParticles(from: gradientView)
                        setParticles(baseView: gradientView, emitterNode: emitterNode)
                    
                    }
                }
                
                
            }

            //if particleToDisplay not nil, will set emitternode to particle
            
        }
    }
    

    
    
    
    
    
    
    
    
//MARK: - UI FUNCTIONS
    
    
    
    
    
    
    //MARK: App Launch Functions
    
    func addHill(){
        
        //setup for mask of hill
        let hillMask = UIImageView()
        hillMask.image = UIImage(named: "hills")
        hillMask.frame = hillView.bounds
        hillView.mask = hillMask
        
    }
    
    
    //Add drop shadows for UILabels
    func addTextShadow(){
        todayButton.titleLabel?.textDropShadow()
        tomorrowButton.titleLabel?.textDropShadow()
        dayAfterButton.titleLabel?.textDropShadow()

    }
    
    //Adds blur to the uiview
    func addBlur(){
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

                UIView.animate(withDuration: 0.4){
                    blurEffectView.effect = blurEffect
                    vibrancyView.effect = vibrancyEffect
                }
            } else {
                view.backgroundColor = .clear
            }
        
    }
    
    //Sets gradient up for initial app launch
    func addGradient(){
    
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
    
    
    
    
    
    
    //MARK: Other Functions

    //MARK: AddParticles
    func setParticles(baseView: UIView, emitterNode: SKEmitterNode) {

        let skView = SKView(frame: CGRect(x:0, y:-200, width: baseView.frame.width, height: baseView.frame.height))
        let skScene = SKScene(size: baseView.frame.size)
        skScene.backgroundColor = .clear
        skScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        skScene.addChild(emitterNode)
        skView.backgroundColor = .clear
        skView.presentScene(skScene)
        skView.isUserInteractionEnabled = false
        skView.tag = 1
        emitterNode.position.y = skScene.frame.maxY
        emitterNode.particlePositionRange.dx = skScene.frame.width
        baseView.addSubview(skView)
    }


    //MARK: RemoveParticles
    func removeParticles(from view: UIView) {
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.removeFromSuperview()
            print("Particles Removed")
        }else{
            print("Error removinig Particles")
        }
        
    }

    func hideParticles(view: UIView) {
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.isHidden = true
        }else{
            print("Error Hiding particles")
        }
        
    }
    func showParticles(view: UIView) {
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.isHidden = false
        }else{
            print("Error Showing particles")
        }
    }
    

    
    //Highlights currently selected button
    func highlightButton(_ buttonToHighlight: UIButton){
        todayButton.alpha = 0.5
        tomorrowButton.alpha = 0.5
        dayAfterButton.alpha = 0.5
        buttonToHighlight.alpha = 1
    }
    
    
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
    

    func removeBlur(){
        if let blurView = view.viewWithTag(2) as? UIVisualEffectView{
            UIView.animate(withDuration: 0.3){
                blurView.effect = nil
            }
        }
    }
    
    func updateBlur(){
        if daySelected == 2{
            if let blurView = view.viewWithTag(2) as? UIVisualEffectView{
                UIView.animate(withDuration: 0.3){
                    blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                }
            }else{
                addBlur()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//MARK: - SEGUES
    
    
    //Called on segue to menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier{
            case C.segues.mainToWeather:
                weatherVC = segue.destination as? WeatherViewController
            case C.segues.mainToDetails:
                detailsVC = segue.destination as? DetailsViewController
            default:
                break
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    

}










//MARK: - EXTENSIONS



//MARK: Location

extension MainViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        
        if let location = locations.last{
            
            do{
                try self.realm.write{
                    let oldLocations = self.realm.objects(MenuItem.self).filter("isCurrentLocation == %@", true)
                    self.realm.delete(oldLocations)
                }
            }catch{
                print(error)
            }
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
        print(error)
    }
    
}














//MARK: WeatherManagerDelegate

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
                        newItem.cityName = self.weatherModel?.locationName

                        
                        
                        newItem.isCurrentLocation = self.weatherModel!.isCurrentLocation
                        
                        
                        let colorName = "\(self.weatherModel!.current.conditionName)_\(self.weatherModel!.current.isDayString)"
                        
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

//MARK: EXT Label

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



