import UIKit

protocol SettingsViewControllerDelegate{
    
    func didChangeUnits()
    
}


class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var unitsPicker: UISegmentedControl!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var defaultLocationPicker: UISegmentedControl!
    @IBOutlet weak var defaultLocationLabel: UILabel!
    
    @IBOutlet weak var adsButton: ButtonStyle!
    @IBOutlet weak var adsLabel: UILabel!
    @IBOutlet weak var adsButtonSpinner: UIActivityIndicatorView!
    
    
    let defaults = UserDefaults.standard
    
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///Localised strings
        titleLabel.text = NSLocalizedString("SETTINGS_TITLE", comment: "Title for page")
        unitsLabel.text = NSLocalizedString("SETTINGS_TEXT_UNITS", comment: "Units label")
        defaultLocationLabel.text = NSLocalizedString("SETTINGS_TEXT_DEFAULT_LOCATION", comment: "default location label")
        defaultLocationPicker.setTitle(NSLocalizedString("SETTINGS_SWITCH_LAST_VIEWED", comment: "Text for default locaiton option on picker"), forSegmentAt: 1)
        ///
        
        
        setAlpha()
        adsButtonSetup()
        
        unitsPicker.selectedSegmentIndex = defaults.integer(forKey: C.defaults.units)
        defaultLocationPicker.selectedSegmentIndex = defaults.integer(forKey: C.defaults.defaultToGPS)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewSetup()
    }
    

    
    func adsButtonSetup(){
        
        adsButton.topGradient = "remove_top"
        adsButton.bottomGradient = "remove_bottom"
        adsButtonSpinner.stopAnimating()
        adsButton.titleLabel?.alpha = 1
        
    }
    
    func setAlpha(){
        
        titleLabel.alpha            = 0
        unitsPicker.alpha           = 0
        unitsLabel.alpha            = 0
        defaultLocationLabel.alpha  = 0
        defaultLocationPicker.alpha = 0
        adsButton.alpha             = 0
        adsLabel.alpha              = 0
        
    }
    
    func viewSetup(){
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
            let blurEffectView = UIVisualEffectView(effect: nil)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: nil)
            vibrancyView.frame = self.view.bounds
            vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            blurEffectView.tag = 3
            
            view.insertSubview(blurEffectView, at: 0)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            UIView.animate(withDuration: 0.2, delay: 0.05){
                
                blurEffectView.effect = blurEffect
                vibrancyView.effect = vibrancyEffect
                
            }
            UIView.animate(withDuration: 0.2, delay: 0.3){
                self.titleLabel.alpha = 1

            }
            UIView.animate(withDuration: 0.2, delay: 0.5){
                self.unitsLabel.alpha = 1
                

            }
            UIView.animate(withDuration: 0.2, delay: 0.6){
                self.defaultLocationLabel.alpha = 1
                self.unitsPicker.alpha          = 1
            }
            UIView.animate(withDuration: 0.2, delay: 0.7){
                self.defaultLocationPicker.alpha = 1
                self.adsLabel.alpha       = 1
            }
            UIView.animate(withDuration: 0.2, delay: 0.8){
                self.adsButton.alpha        = 1
            }
            
        } else {
            view.backgroundColor = .darkGray
        }
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unitsPicker(_ sender: UISegmentedControl) {
        
        let val = sender.selectedSegmentIndex == 1 ? 1 : 0
        defaults.setValue(val, forKey: C.defaults.units)
        delegate?.didChangeUnits()
        
        
    }
    
    @IBAction func defaultLocationPicker(_ sender: UISegmentedControl) {
        
        let val = sender.selectedSegmentIndex == 1 ? 1 : 0
        defaults.setValue(val, forKey: C.defaults.defaultToGPS)
        
    }
    
    @IBAction func removeAdsButtonPressed(_ sender: ButtonStyle) {
        
        UIView.animate(withDuration: 0.1) {
            sender.titleLabel?.alpha = 0
        }
        sender.topGradient = "grad_menu_bottom"
        sender.bottomGradient = "grad_menu_top"
        self.adsButtonSpinner.startAnimating()
    }
    
}
