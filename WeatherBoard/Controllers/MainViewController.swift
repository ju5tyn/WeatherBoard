import UIKit
import CoreLocation
import SpriteKit
import RealmSwift
import LTMorphingLabel
import ZSegmentedControl




class MainViewController: UIViewController{
    
    
    //MARK: - OUTLETS
    
    //views
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var hillView: UIView!
    @IBOutlet weak var weatherContainerView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
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
    @IBOutlet weak var hillViewBottomConstraint: NSLayoutConstraint!
    
    
    //Location label header
    @IBOutlet weak var locationLabelView: UIView!
    @IBOutlet weak var locationLabel: LTMorphingLabel!
    @IBOutlet weak var locationLabelLeadingConstraint: NSLayoutConstraint!
    
    
    
    
    
    //MARK: - VARIABLES
    
    
    
    var pageSelected: Pages = .today {
        didSet{
            switchPage()
        }
        
    }
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
    let dataManager = DataManager()
    let locationManager = CLLocationManager()
    
    
    
    let defaults = UserDefaults.standard
    
    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hillViewHeightConstraint.constant = ((self.view.bounds.height))*0.4
        
        overrideUserInterfaceStyle = .dark
        
        weatherManager.delegate     = self
        locationManager.delegate    = self
        
        detailsContainerView.isHidden   = true
        separatorView.isHidden          = true
        
        addHill()
        addGradient()
        addShadows()
        highlightNavButton(.today)
        getLocation()
        clearDetails()
        addGestures()
        
        
        
    }
    
    func addGestures(){
        
        let swipeLeft   = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
        let swipeRight  = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
        
        swipeLeft.direction  = .left
        swipeRight.direction = .right
        
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc func swipedLeft(){
        if pageSelected != .more{
            pageSelected.next()
        }
    }
    
    @objc func swipedRight(){
        if pageSelected != .today{
            pageSelected.prev()
        }
    }
    
    func switchPage(){
        
        switch pageSelected{
            case .today:
                removeBlur()
                highlightNavButton(.today)
            case .tomorrow:
                removeBlur()
                highlightNavButton(.tomorrow)
            case .more:
                updateBlur()
                highlightNavButton(.more)
        }
        
        setLocationLabel(hidden: pageSelected != .more) //hides location label if not on MORE page
        
        pageSelected == .more ?
            viewChange(hide: weatherContainerView, show: detailsContainerView, refresh: false)
            :
            viewChange(hide: detailsContainerView, show: weatherContainerView, refresh: true)
        
        
        
    }
    
    
    
    
    
    //MARK: - Buttons
    
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        
        openMenu()
        
    }
    
    func openMenu(){
        
        
        self.performSegue(withIdentifier: C.segues.mainToMenu, sender: self)
        removeBlur()
        setGradientColor(color: "menu")
        setParticles(view: view, hidden: true)
        
        UIView.animate(withDuration: 0.2) {
            self.mainView.alpha = 0.0
        }
        
        menuOpen.toggle()
        
    }
    
    
    @IBAction func navButtonPressed(_ sender: UIButton) {
        
        switch sender.titleLabel!.text{
            case "TODAY":
                pageSelected = .today
            case "TOMORROW":
                pageSelected = .tomorrow
            case "MORE":
                pageSelected = .more
            default:
                print("error in nav buttons")
        }
        
        
    }
    
    
    
    
    
    //MARK: - FUNCTIONS
    
    func getLocation(){
        
        //Requests user location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        
        let previousLocationName = defaults.string(forKey: C.defaults.defaultLocation)
        
        if ((previousLocationName != nil) && (defaults.integer(forKey: C.defaults.defaultToGPS) == 1)){
            weatherManager.fetchWeather(cityName: previousLocationName!, doNotSave: true)
        }else{
            locationManager.requestLocation()
        }
        
    }
    
    
    
    //resets weather details to empty
    func clearDetails(){
        setLocationLabel(hidden: true)
        weatherVC?.clearWeatherDetails()
        detailsVC?.clearWeatherDetails()
        setGradientColor(color: "menu")
        removeParticles(from: gradientView)
        hideNavButtons(hidden: true)
    }
    
    
    //use when loading data from existing weathermodel
    func changeDetails() {
        if (weatherModel != nil && weatherModel?.locationName != nil){
            
            weatherVC?.setWeatherDetails(using: weatherModel!, page: pageSelected)
            detailsVC?.setWeatherDetails(using: weatherModel!)
            locationLabel.text = weatherModel?.locationName?.uppercased()
            updateGraphics()
        }else{
            showAlert(with: nil)
        }
    }
    
    func updateGraphics(){
        updateBlur()
        if (weatherModel != nil && weatherModel?.locationName != nil){

            updateGradients()
            updateParticles()
        }
        
    }
    
    func updateGradients(){
        
        if pageSelected == .more{
            setGradientColor(color: "\(weatherModel!.daily[1].conditionName)_\(weatherModel!.current.isDayString)")
            setLocationLabel(hidden: false)
        }else{
            if pageSelected == .today {
                
                if weatherModel!.current.isSunset{
                    setGradientColor(color: "sunset")
                }else if weatherModel!.current.isSunrise{
                    setGradientColor(color: "sunrise")
                }else{
                    setGradientColor(color: "\(weatherModel!.current.conditionName)_\(weatherModel!.current.isDayString)")
                }
                
                
            }else{
                self.setGradientColor(color: "\(weatherModel!.daily[1].conditionName)_\(weatherModel!.current.isDayString)")
            }
        }
        
        
    }
    
    func updateParticles(){
        
        if pageSelected == .today{
            if let particleToDisplay = weatherModel?.current.particle{
                emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                removeParticles(from: gradientView)
                addParticles(baseView: gradientView, emitterNode: emitterNode)
                
            }else {
                removeParticles(from: gradientView)
            }
        }else {
            if let particleToDisplay = weatherModel?.daily[1].particle{
                emitterNode = SKEmitterNode(fileNamed: String(particleToDisplay))!
                removeParticles(from: gradientView)
                addParticles(baseView: gradientView, emitterNode: emitterNode)
            }else {
                removeParticles(from: gradientView)
            }
        }
        
        
    }
    
    
    
    //sets weather details to contents of weathermodel
    //Use when loading new weatherModel
    func setDetails(){
        if weatherModel != nil {
            hideNavButtons(hidden: false)
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: weatherModel!.lat, longitude: weatherModel!.lon), completionHandler: { [self] placemarks, error in
                
                var locationName: String? = placemarks?.first?.locality
                if locationName == nil {
                    locationName = placemarks?.first?.country
                }
                self.weatherModel?.locationName = locationName
                
                if weatherModel?.locationName != nil {
                    changeDetails()
                } else {
                    showAlert(with: nil)
                }
            }
            )
        } else {
            
            showAlert(with: nil)
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    //MARK:  UI FUNCTIONS
    
    func setLocationLabel(hidden: Bool){
        
        UIView.animate(withDuration: 0.2){
            self.locationLabelView.alpha = hidden ? 0 : 1
            self.locationLabelLeadingConstraint.constant = hidden ? 50 : 70
            self.locationLabelView.setNeedsLayout()
            self.locationLabelView.superview?.layoutIfNeeded()
        }
        
        
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
        
        //setup for mask of hill
        let hillMask = UIImageView()
        
        hillMask.frame = CGRect.init(x: 0, y: 0, width: UIScreen.screens[0].bounds.width, height: UIScreen.screens[0].bounds.height*0.4)
        
        hillMask.image = UIImage(named: "hills")
        hillMask.clipsToBounds = false
        
        hillView.autoresizesSubviews = true
        hillView.mask = hillMask
        
        
        
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
        
        hillGradient.frame = CGRect.init(x: 0, y: 0, width: UIScreen.screens[0].bounds.width, height: UIScreen.screens[0].bounds.height*0.4)
        hillView.layer.addSublayer(hillGradient)
        hillGradient.startPoint = CGPoint(x: 0.5, y: 1)
        hillGradient.endPoint = CGPoint(x: 0.5, y: 0)
        
        setGradientColor(color: "menu")
        
    }
    
    
    
    
    
    
    //MARK: Other Functions
    
    
    
    
    //MARK: Particles
    func addParticles(baseView: UIView, emitterNode: SKEmitterNode) {
        
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
            print("⚠️ Error Removing Particles")
        }
        
    }
    
    func setParticles(view: UIView, hidden: Bool){
        if let viewWithTag = view.viewWithTag(1){
            viewWithTag.isHidden = hidden
        }else{
            print("⚠️ Error Hiding particles")
        }
    }
    
    
    
    enum Buttons {
        case today
        case tomorrow
        case more
    }
    //Highlights currently selected button
    func highlightNavButton(_ buttonToHighlight: Buttons){
        
        todayButton.alpha = 0.5
        tomorrowButton.alpha = 0.5
        dayAfterButton.alpha = 0.5
        
        switch buttonToHighlight{
            case .today:
                todayButton.alpha = 1
            case .tomorrow:
                tomorrowButton.alpha = 1
            case .more:
                dayAfterButton.alpha = 1
        }
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
        if pageSelected == .more{
            if let blurView = view.viewWithTag(2) as? UIVisualEffectView{
                UIView.animate(withDuration: 0.3){
                    blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                }
            }else{
                addBlur()
            }
        }
    }
    
    
    
    func showAlert(with error: Error?){
        
        DispatchQueue.main.async {
            
            let failedAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            failedAlert.title = "Error loading weather"
            if let errorMessage = error?.localizedDescription {
                failedAlert.message = errorMessage
            }else{
                failedAlert.message = "An unknown error occured"
            }

            failedAlert.addAction(UIAlertAction(title: "Go to Menu",
                                                style: .destructive,
                                                handler: {_ in
                                                    self.openMenu()
                                                }))
            
            self.present(failedAlert, animated: true)
            
            self.weatherVC?.showAlertScreen()
            self.setGradientColor(color: "delete")
            
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
            case C.segues.mainToMenu:
                let menuVC = segue.destination as? MenuViewController
                menuVC?.loadViewIfNeeded()
                menuVC?.delegate = self
                
            default:
                break
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        
        switch segue.identifier{
            case C.segues.mainToWeather:
                weatherVC = segue.destination as? WeatherViewController
            case C.segues.mainToDetails:
                detailsVC = segue.destination as? DetailsViewController
            default:
                break
        }
        
    }
    
    
}










//MARK: - EXTENSIONS


//MARK: - MenuViewControllerDelegate

extension MainViewController: MenuViewControllerDelegate{
    
    func menuViewControllerDidEnd(_ menuViewController: MenuViewController) {
        
        UIView.animate(withDuration: 0.5) {
            self.mainView.alpha = 1
        }
        menuViewController.dismiss(animated: true, completion: nil)
        
    }
    
    //Clears details ready for new data to be displayed
    func menuViewControllerDidRequestReload(_ menuViewController: MenuViewController) {
        //menuOpen = false
        clearDetails()
        menuViewControllerDidEnd(menuViewController)
    }
    
    //Called on exit of menu if no request was made
    func menuViewControllerDidDismissWithNoRequest(_ menuViewController: MenuViewController) {
        updateGraphics()
        menuViewControllerDidEnd(menuViewController)
    }
    
    //Called when user location is requested
    func menuViewControllerDidRequestLocation(_ menuViewController: MenuViewController) {
        menuViewControllerDidRequestReload(menuViewController)
        locationManager.requestLocation()
    }
    
    //Called when a specific search result is pressed
    func menuViewControllerDidSearchResultPressed(_ menuViewController: MenuViewController, lat: Double, lon: Double) {
        menuViewControllerDidRequestReload(menuViewController)
        weatherManager.fetchWeather(latitude: lat, longitude: lon, doNotSave: false)
        
    }
    
    func menuViewControllerDidRecentPressed(_ menuViewController: MenuViewController, lat: Double, lon: Double){
        menuViewControllerDidRequestReload(menuViewController)
        weatherManager.fetchWeather(latitude: lat, longitude: lon, doNotSave: false)
    }

    
    
}




//MARK: Location

extension MainViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        
        if let location = locations.last{

            DispatchQueue.main.async {
                self.dataManager.deleteOldLocations()
            }
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error){
        print(error.localizedDescription)
        print("MIKE PENIS NOT HAPPY")
        
        
        showAlert(with: error)
    }
    
}














//MARK: WeatherManagerDelegate

extension MainViewController: WeatherManagerDelegate{
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weatherModel: WeatherModel){
        
        self.weatherModel = weatherModel
        //sets this view's weather model to data from weathermanager
        DispatchQueue.main.async {
            self.dataManager.saveWeatherModel(weatherModel)
            self.setDetails()
        }
    }
    
    func didFailWithError(error: Error){
        print(error.localizedDescription)
        
        print("❌ Error: Invalid Location")
        
        showAlert(with: error)
        
        
        
        
    }
}

//MARK: Extensions

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

extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}
