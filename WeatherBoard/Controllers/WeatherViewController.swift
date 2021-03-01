import UIKit
import LTMorphingLabel
import CoreLocation

class WeatherViewController: UIViewController {
    
    //elements
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: LTMorphingLabel!
    @IBOutlet weak var timeLocationLabel: LTMorphingLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempLabel.morphingEffect = .evaporate
        timeLocationLabel.morphingEffect = .evaporate
        
        tempLabel.textDropShadow()
        timeLocationLabel.textDropShadow()
        
        
        // Do any additional setup after loading the view.
    }
    
    func clearWeatherDetails(){
        
        weatherImageView.image = nil
        tempLabel.text = "Loading"
        timeLocationLabel.text = ""
        activityIndicator.startAnimating()
        
    }
    
    func setWeatherDetails(using weatherModel: WeatherModel, day daySelected: Int){
        
        //sets tempLabel label to temperature followed by condition
        if daySelected == 0 {
            tempLabel.text = "\(weatherModel.hourly[0].tempString) \(weatherModel.current.fullName!)"
            
            //sets weather image to string based on condition and day/night
            weatherImageView.setImage(UIImage(named: "icon_\(weatherModel.hourly[0].conditionName)_\(weatherModel.hourly[0].isDayString)"))
            
        }else if daySelected == 1 {
            
            tempLabel.text = "\(weatherModel.daily[1].tempString) \(weatherModel.daily[1].fullName!)"
            
            //sets weather image to string based on condition and day/night
            weatherImageView.setImage(UIImage(named: "icon_\(weatherModel.daily[1].conditionName)_\(weatherModel.current.isDayString)"))
        }
        
        self.timeLocationLabel.text = "\(weatherModel.timeString) - \(weatherModel.locationName!)"
        
        activityIndicator.stopAnimating()
        
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




