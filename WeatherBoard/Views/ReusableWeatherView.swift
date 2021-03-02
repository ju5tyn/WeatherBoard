//
//  ReusableWeatherView.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 02/03/2021.
//  Copyright © 2021 Justyn Henman. All rights reserved.
//

import UIKit
import LTMorphingLabel

class ReusableWeatherView: UIView {
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: LTMorphingLabel!
    @IBOutlet weak var timeLocationLabel: LTMorphingLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    let nibName = "ReusableWeatherView"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tempLabel.morphingEffect = .evaporate
        timeLocationLabel.morphingEffect = .evaporate
        
        tempLabel.textDropShadow()
        timeLocationLabel.textDropShadow()
        
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
