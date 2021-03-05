import UIKit
import LTMorphingLabel
import CoreLocation
import ZSegmentedControl



class WeatherViewController: UIViewController{
    
    
        
    //elements
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: LTMorphingLabel!
    @IBOutlet weak var timeLocationLabel: LTMorphingLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: ZSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempLabel.morphingEffect = .evaporate
        timeLocationLabel.morphingEffect = .evaporate
        
        tempLabel.textDropShadow()
        timeLocationLabel.textDropShadow()
        
        //segmentedControl.delegate = self
        segmentedControl.setTitles([""], style: .adaptiveSpace(15))
        setupSegmentedControl()


    }
    

    
    func setupSegmentedControl(){
        
        var arr: [String] = []
        arr.append("NOW")
        arr.append("19")
        arr.append(contentsOf: ["1", "12", "2", "4", "6", "8"])
        
        segmentedControl.setTitles(arr, style: .adaptiveSpace(15))
        segmentedControl.setCover(color: UIColor.init(white: 1, alpha: 0.3),
                                  upDowmSpace: 10,
                                  cornerRadius: 13)
        segmentedControl.selectedScale      = 1
        segmentedControl.bounces            = true
        segmentedControl.backgroundColor    = .clear
        segmentedControl.textSelectedColor  = .white
        segmentedControl.textColor          = .white
        segmentedControl.textFont           = UIFont(name: "Roboto-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)
        
        segmentedControl.addShadow()
        
        segmentedControl.setNeedsDisplay()
        segmentedControl.setNeedsLayout()
    }
    


    
    
    func clearWeatherDetails(){
        
        weatherImageView.image = nil
        tempLabel.text = "Loading"
        timeLocationLabel.text = ""
        activityIndicator.startAnimating()
        
    }
    
    //version OG
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




