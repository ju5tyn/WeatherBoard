import UIKit

class WeatherViewController: UIViewController {
    
    
    
    
    //elements
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLocationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempLabel.textDropShadow()
        timeLocationLabel.textDropShadow()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
}

extension WeatherViewController{
    
    func clearWeatherDetails(){
        print("details cleared")
        weatherImageView.image = nil
        tempLabel.text = "HAHAHAH"
        timeLocationLabel.text = ""
        activityIndicator.startAnimating()
    
    }
    
    
}
