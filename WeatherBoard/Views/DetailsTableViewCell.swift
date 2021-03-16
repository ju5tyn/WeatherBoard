//
//  DetailsTableViewCell.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 09/10/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var mainTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var detailStack: UIStackView!
    
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var windDirectionImageView: UIImageView!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //constraints
    @IBOutlet weak var dayLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTempLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTempLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    
    //boxes
    @IBOutlet weak var precipView: UIView!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var cloudCoverView: UIView!
    @IBOutlet weak var visibilityView: UIView!
    @IBOutlet var boxViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDisplay()
        isSelected ? setBig() : setSmall()
        
    }
    
    //MARK: - Runs when Cell Selected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selected ? setBig() : setSmall()
        
    }
    
    func setupDisplay(){
        
        conditionLabel.textDropShadow()
        dayLabel.textDropShadow()
        mainTempLabel.textDropShadow()
        
        for box in boxViews{
            box.layer.cornerRadius  = 10
            box.layer.shadowOpacity = 0.3
            box.layer.shadowOffset  = .init(width: 0, height: 1)
            box.layer.shadowRadius  = 5
            box.layer.masksToBounds = false
        }
        
    }
    
    
    
    
    
    func setViews(hidden: Bool){
        
        hidden ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()

        weatherImageView.isHidden  = hidden
        mainTempLabel.isHidden     = hidden
        highTempLabel.isHidden     = hidden
        lowTempLabel.isHidden      = hidden
        detailStack.isHidden       = hidden
        conditionLabel.isHidden    = hidden

    }
    
    
    func setData(with day: WeatherModel.Daily, isDayString: String){
        
        weatherImageView.setImage(UIImage(named: "icon_\(day.conditionName)_\(isDayString)"), animated: true)

        mainTempLabel.text      = day.tempString
        conditionLabel.text     = day.smallName
        precipLabel.text        = day.precipString
        windSpeedLabel.text     = day.windSpeedString
        windDirectionLabel.text = day.windDirectionString
        cloudCoverLabel.text    = day.cloudCoverString
        //cell.visibilityLabel.text = day.visibilityString

        if (day.highTemp != day.lowTemp){
            highTempLabel.text = day.highTempString
            lowTempLabel.text = day.lowTempString
        }else{
            highTempLabel.text = ""
            lowTempLabel.text = ""
            highTempLabel.isHidden = true
            lowTempLabel.isHidden  = true
        }
        
    }

    
    //MARK: - Set Big
    
    func setBig(){
        
        activityIndicator.style = .large
        conditionLabel.layer.masksToBounds = false
        
        UIView.animate(withDuration: 0.2){ [self] in
            
            self.imageWidthConstraint.constant  = 100
            self.imageHeightConstraint.constant = 100
            
            self.setNeedsLayout()
            
            mainTempLabel.font = mainTempLabel.font.withSize(50)
            
            mainTempLabelTopConstraint.constant         = 100
            mainTempLabelTrailingConstraint.constant    = 60
            dayLabelTopConstraint.constant              = 100
            
            dayLabel.alpha          = 0.6
            highTempLabel.alpha     = 0.6
            lowTempLabel.alpha      = 0.6
            conditionLabel.alpha    = 1
            
            layoutIfNeeded()
        }
        var count: Double = 0.2
        
        //Animation for boxViews
        for view in boxViews{
            UIView.animate(withDuration: 0.2, delay: count){
                view.alpha = 1
            }
            count+=0.05
        }
        layoutIfNeeded()
    }
    
    
    
    
    //MARK: - Set Small
    func setSmall(){
        
        activityIndicator.style = .medium
        conditionLabel.layer.masksToBounds = false
        
        UIView.animate(withDuration: 0.2){ [self] in
            self.imageWidthConstraint.constant  = 50
            self.imageHeightConstraint.constant = 50
            
            self.setNeedsLayout()
            
            mainTempLabel.font = mainTempLabel.font.withSize(25)
            
            mainTempLabelTopConstraint.constant = 10
            mainTempLabelTrailingConstraint.constant = 96
            dayLabelTopConstraint.constant = 15
            
            dayLabel.alpha          = 1
            highTempLabel.alpha     = 0
            lowTempLabel.alpha      = 0
            conditionLabel.alpha    = 0
            
            for view in boxViews{
                view.alpha = 0
            }

            layoutIfNeeded()
        }
    }
}

