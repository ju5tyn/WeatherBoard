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
    @IBOutlet weak var rainLabel: LTMorphingLabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempLabel.morphingEffect = .evaporate
        timeLocationLabel.morphingEffect = .evaporate
        rainLabel.morphingEffect = .evaporate
        
        tempLabel.textDropShadow()
        timeLocationLabel.textDropShadow()
        
        //segmentedControl.delegate = self
        segmentedControl.clearsContextBeforeDrawing = true
        //setupSegmentedControl()


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
    

    func showAlertScreen(){
        
        clearWeatherDetails()
        tempLabel.text               = "(ノಠ益ಠ)ノ彡┻━┻"
        timeLocationLabel.text       = "An error occurred"
        activityIndicator.stopAnimating()
        
    }
    
    
    func clearWeatherDetails(){
        
        weatherImageView.image = nil
        tempLabel.text = "Loading"
        timeLocationLabel.text = " "
        rainLabel.text = " "
        activityIndicator.startAnimating()
        
    }
    
    //version OG
    func setWeatherDetails(using weatherModel: WeatherModel, page pageSelected: Pages){
        
        
        
        //sets tempLabel label to temperature followed by condition
        if pageSelected == .today {

            tempLabel.text = "\(weatherModel.current.tempString) \(weatherModel.current.fullName!)"
            
            //sets weather image to string based on condition and day/night
            weatherImageView.setImage(UIImage(named: "icon_\(weatherModel.current.conditionName)_\(weatherModel.current.isDayString)"))
            
            if let rain = weatherModel.rainInfo {
                
                switch rain.type{
                    case .starting:
                        timeLocationLabel.text = "Rain starting in \(getRainLabel(rain.minutes!))"
                    case .stopping:
                        timeLocationLabel.text = "Rain stopping in \(getRainLabel(rain.minutes!))"
                    case .wholeHour:
                        timeLocationLabel.text = "Rain for the hour"
                }
                

            }else{
                
                self.timeLocationLabel.text = "\(weatherModel.timeString) - \(weatherModel.locationName!)"
                
                
            }
            
            
        }else if pageSelected == .tomorrow {

            tempLabel.text = "\(weatherModel.daily[1].tempString) \(weatherModel.daily[1].fullName!)"

            //sets weather image to string based on condition and day/night
            weatherImageView.setImage(UIImage(named: "icon_\(weatherModel.daily[1].conditionName)_\(weatherModel.current.isDayString)"))

            self.timeLocationLabel.text = "\(weatherModel.timeString) - \(weatherModel.locationName!)"
   
        }

        activityIndicator.stopAnimating()
        
    }
    

    
    
    func getRainLabel(_ minutes: Int) -> String{
        
        if minutes == 1{
            return "\(minutes) minute"
        }else{
            return "\(minutes) minutes"
        }
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




