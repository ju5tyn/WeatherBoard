import UIKit
import LTMorphingLabel

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
        print("details cleared")
        weatherImageView.image = nil
        tempLabel.text = "Loading"
        timeLocationLabel.text = ""
        activityIndicator.startAnimating()
    
    }
    
    func setWeatherDetails(using weatherModel: WeatherModel, day daySelected: Int){
 
        //sets tempLabel label to temperature followed by condition
        tempLabel.text = "\(weatherModel.fiveDayArray[daySelected].tempString) \(weatherModel.fiveDayArray[daySelected].description)"
                //sets time/location label to time in location followed by name of location
        timeLocationLabel.text = "\(weatherModel.timeString) - \(weatherModel.cityName)"

        //sets weather image to string based on condition and day/night
        weatherImageView.setImage(UIImage(named: "icon_\(weatherModel.fiveDayArray[daySelected].conditionName)_\(weatherModel.isDayString)"))
        
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


