import UIKit
import CoreLocation
import SpriteKit
import RealmSwift
import LTMorphingLabel

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
    
    //constraints
    @IBOutlet weak var navButtonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var hillViewHeightConstraint: NSLayoutConstraint!
    
    
    
    //Location label header
    @IBOutlet weak var locationLabelView: UIView!
    @IBOutlet weak var locationLabel: LTMorphingLabel!
    @IBOutlet weak var locationLabelLeadingConstraint: NSLayoutConstraint!
    
    
    
    
    
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
        
        
        print(UIFont(name: "Roboto-black", size: 10)!)
        print(UIFont(name: "Roboto-Bold", size: 10)!)

        
        
        overrideUserInterfaceStyle = .dark
        weatherManager.delegate = self
        locationManager.delegate = self
        detailsContainerView.isHidden = true
        
        addHill()
        addGradient()
        addShadows()
        highlightButton(todayButton)
        getLocation()
        clearDetails()
        
        for family: String in UIFont.familyNames
               {
                   print(family)
                   for names: String in UIFont.fontNames(forFamilyName: family)
                   {
                       print("== \(names)")
                   }
               }
        
        
    }
    
    
    
    
    
    
    
    
    //MARK: - Buttons
    
    
    
    //MARK: Menu Pressed
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: C.segues.mainToMenu, sender: self)
        removeBlur()
        setGradientColor(color: "menu")
        hideParticles(view: view)
        
        UIView.animate(withDuration: 0.2) {
            self.mainView.alpha = 0.0
        }
        //mainView.isHidden = true
        
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
                animateLocationLabelOut()
            case "TOMORROW":
                daySelected = 1
                removeBlur()
                animateLocationLabelOut()
            default:
                daySelected = 2
                updateBlur()
                animateLocationLabelIn()
        }
        
        daySelected == 2 ?
            viewChange(hide: weatherContainerView, show: detailsContainerView, refresh: false)
            :
            viewChange(hide: detailsContainerView, show: weatherContainerView, refresh: true)
        
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - FUNCTIONS
    
    func getLocation(){
        //Requests user location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.requestLocation()
    }
    
    
    
    //MARK: clearDetails
    //resets weather details to empty
    func clearDetails(){
        animateLocationLabelOut()
        weatherVC?.clearWeatherDetails()
        detailsVC?.clearWeatherDetails()
        setGradientColor(color: "menu")
        removeParticles(from: gradientView)
        hideNavButtons(hidden: true)
    }
    
    //MARK: Change details
    
    func changeDetails() {
        if weatherModel?.locationName != nil {
            
            weatherVC?.setWeatherDetails(using: weatherModel!, day: daySelected)
            detailsVC?.setWeatherDetails(using: weatherModel!)
            
            locationLabel.text = weatherModel?.locationName?.uppercased()

            //sets gradient color with string based on condition and day/night
            if daySelected == 2{
                if menuOpen == false {

                    self.setGradientColor(color: "\(weatherModel!.daily[1].conditionName)_\(weatherModel!.current.isDayString)")
                    animateLocationLabelIn()
                }
            }else{
                if menuOpen == false {
                    
                    if self.daySelected == 0 {
                        
                        if weatherModel!.current.isSunset{
                            self.setGradientColor(color: "sunset")
                        }else if weatherModel!.current.isSunrise{
                            self.setGradientColor(color: "sunrise")
                        }else{
                            self.setGradientColor(color: "\(weatherModel!.current.conditionName)_\(weatherModel!.current.isDayString)")
                        }
                    }else{

                        self.setGradientColor(color: "\(weatherModel!.daily[1].conditionName)_\(weatherModel!.current.isDayString)")
                    }
                }
            }
            //print(daySelected)
            
            /*
            if self.daySelected == 0{
                if let particleToDisplay = weatherModel?.current.particle{
                    
                    let newNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                    
                    if (emitterNode.particleTexture != newNode.particleTexture) {

                        emitterNode = newNode
                        removeParticles(from: gradientView)
                        setParticles(baseView: gradientView, emitterNode: emitterNode)
                    }
                }
            }else {
                print(weatherModel?.daily[1].particle ?? "loll")
                print("epic")
                if let particleToDisplay = weatherModel?.daily[1].particle{
                    
                    let newNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                    
                    if (emitterNode.particleTexture != newNode.particleTexture) {
                        
                        emitterNode = newNode
                        removeParticles(from: gradientView)
                        setParticles(baseView: gradientView, emitterNode: emitterNode)
                    }
 
                }
            }
            */
            
            if self.daySelected == 0{
                if let particleToDisplay = weatherModel?.current.particle{
                    
                    emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                    removeParticles(from: gradientView)
                    setParticles(baseView: gradientView, emitterNode: emitterNode)
                    
                }else {
                    removeParticles(from: gradientView)
                    //setParticles(baseView: gradientView, emitterNode: emitterNode)
                }
            }else {
                if let particleToDisplay = weatherModel?.daily[1].particle{
                    
                    //let newNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                    //emitterNode = newNode
                    emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                    removeParticles(from: gradientView)
                    setParticles(baseView: gradientView, emitterNode: emitterNode)
                    
 
                }else {
                    removeParticles(from: gradientView)
                    //setParticles(baseView: gradientView, emitterNode: emitterNode)
                }
            }
            
        } else {
            //catches error from spamming buttons
            print("error")
        }
    }
    
    
    //MARK: setDetails
    //sets weather details to contents of weathermodel
    func setDetails(){
        if weatherModel != nil {
            hideNavButtons(hidden: false)
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: weatherModel!.lat, longitude: weatherModel!.lon), completionHandler: { [self] placemarks, error in
                
                var locationName: String? = placemarks?.first?.locality
                if locationName == nil {
                    locationName = placemarks?.first?.country
                }
                self.weatherModel?.locationName = locationName
                
                
                /*
                if self.daySelected == 0{
                    if let particleToDisplay = weatherModel?.current.particle{
                        
                        let newNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                        emitterNode = newNode
                        removeParticles(from: gradientView)
                        setParticles(baseView: gradientView, emitterNode: emitterNode)
                        
                    }
                }else {
                    if let particleToDisplay = weatherModel?.daily[1].particle{
                        
                        let newNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                        emitterNode = newNode
                        removeParticles(from: gradientView)
                        setParticles(baseView: gradientView, emitterNode: emitterNode)
                        
     
                    }
            }
 */
                //print(weatherModel?.locationName)
                changeDetails()
                
            }
            )
        }
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: - UI FUNCTIONS
    
    func animateLocationLabelIn(){
        
        UIView.animate(withDuration: 0.2){
            self.locationLabelView.alpha = 1
            self.locationLabelView.setNeedsLayout()
            self.locationLabelLeadingConstraint.constant = 70
            self.locationLabelView.superview?.layoutIfNeeded()
        }
        //locationLabelView.isHidden = false
        
    }
    
    func animateLocationLabelOut(){
        
        UIView.animate(withDuration: 0.2){
            self.locationLabelView.alpha = 0
            
            self.locationLabelLeadingConstraint.constant = 50
            self.locationLabelView.setNeedsLayout()
            self.locationLabelView.superview?.layoutIfNeeded()
            
        }
        //locationLabelView.isHidden = true
        
    }
    
    
    
    
    func viewChange(hide viewToHide: UIView, show viewToShow: UIView, refresh: Bool){
        
        UIView.animate(withDuration: 0.3){
            viewToShow.alpha = 1
            viewToHide.alpha = 0
            //self.locationLabel.isHidden.toggle()
        }
        viewToShow.isHidden = false
        viewToHide.isHidden = true
        refresh ? changeDetails() : nil
    }
    
    
    
    
    //MARK: App Launch Functions
    
    func addHill(){
        
        hillViewHeightConstraint.constant = (self.view.bounds.height)*0.4
        
        //setup for mask of hill
        let hillMask = UIImageView()
        hillMask.image = UIImage(named: "hills")
        hillMask.frame = hillView.bounds
        hillMask.sizeToFit()
        hillView.mask = hillMask
        hillView.sizeToFit()
        
        
    }
    
    
    //Add drop shadows for UILabels
    func addShadows(){
        todayButton.titleLabel?.textDropShadow()
        tomorrowButton.titleLabel?.textDropShadow()
        dayAfterButton.titleLabel?.textDropShadow()
        menuButton.addShadow()
        locationLabel.addShadow()
        
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
    
    
    
    
    //MARK: Particles
    func setParticles(baseView: UIView, emitterNode: SKEmitterNode) {
        
        let skView = SKView(frame: CGRect(x:0, y:-200, width: baseView.frame.width, height: baseView.frame.height+200))
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
    

    func removeParticles(from view: UIView) {
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.removeFromSuperview()
            print("Particles Removed")
        }else{
            print("❌ Error Removing Particles")
        }
        
    }
    
    func hideParticles(view: UIView) {
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.isHidden = true
        }else{
            print("❌ Error Hiding particles")
        }
        
    }
    func showParticles(view: UIView) {
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.isHidden = false
        }else{
            print("❌ Error Showing particles")
        }
    }
    
    
    
    //Highlights currently selected button
    func highlightButton(_ buttonToHighlight: UIButton){
        todayButton.alpha = 0.5
        tomorrowButton.alpha = 0.5
        dayAfterButton.alpha = 0.5
        buttonToHighlight.alpha = 1
    }
    
    func hideNavButtons(hidden: Bool){
        if hidden{
            UIView.animate(withDuration: 0.9){
                self.navButtons.alpha = 0.0
            }
            navButtons.isHidden = true
        }else{
            navButtons.isHidden = false
            UIView.animate(withDuration: 0.3){
                self.navButtons.alpha = 1.0
            }
            
        }
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
                let location = CLLocation(latitude: self.weatherModel!.lat, longitude: self.weatherModel!.lon)
                
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                    
                    self.realm.beginWrite()
                    
                    let newItem = MenuItem()
                    newItem.isCurrentLocation = self.weatherModel!.isCurrentLocation
                    
                    var colorName = "menu"
                    
                    if (self.weatherModel!.current.isSunset){
                        colorName = "sunset"
                    } else if (self.weatherModel!.current.isSunrise){
                        colorName = "sunrise"
                    }else{
                        colorName = "\(self.weatherModel!.current.conditionName)_\(self.weatherModel!.current.isDayString)"
                    }
                    
                    
                    
                    newItem.topGradient = "button_\(colorName)_top"
                    newItem.bottomGradient = "button_\(colorName)_bottom"
                    
                    
                    newItem.cityName = placemarks?.first?.locality
                    
                    if newItem.cityName == nil {
                        newItem.cityName = placemarks?.first?.country
                    }
                    
                    
                    self.realm.add(newItem)
                    
                    do{
                        try self.realm.commitWrite()
                    } catch {
                        print(error)
                    }
                })
                
                
                //realm end
            }
            self.setDetails()
            
        }
    }
    
    func didFailWithError(error: Error){
        print(error)
        
        let failedAlert = UIAlertController(title: "Invalid Weather Location", message: "Please enter valid location", preferredStyle: .actionSheet)
        
        failedAlert.show(self, sender: self)
        print("❌ Error: Invalid Location")
        
        
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

extension UIView {
    
    func addShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.5
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    
}
