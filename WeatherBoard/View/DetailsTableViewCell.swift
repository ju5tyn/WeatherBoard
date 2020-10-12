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
    
    
    //constraints
    @IBOutlet weak var dayLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTempLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTempLabelTopConstraint: NSLayoutConstraint!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isSelected{
            //WHEN BIG
            setBig()
        }else{
            //WHEN SMALL
            setSmall()
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected{
            //WHEN BIG
            setBig()
        }else{
            //WHEN SMALL
            setSmall()
        }
    }
    
    
    func setBig(){
        
        weatherImageView.frame.size.height = 100
        weatherImageView.frame.size.width = 100
        
        
        
        self.setNeedsLayout()
        
        mainTempLabel.font = mainTempLabel.font.withSize(50)
        
        detailStack.isHidden = false
        highTempLabel.isHidden = false
        lowTempLabel.isHidden = false
        conditionLabel.isHidden = false
        
        mainTempLabelTopConstraint.constant = 100
        mainTempLabelTrailingConstraint.constant = 30
        dayLabelTopConstraint.constant = 100
        layoutIfNeeded()
        
        
    }
    
    func setSmall(){
        
            weatherImageView.frame.size.height = 50
            weatherImageView.frame.size.width = 50
            
            self.setNeedsLayout()
        
            mainTempLabel.font = mainTempLabel.font.withSize(25)
            
            detailStack.isHidden = true
            highTempLabel.isHidden = true
            lowTempLabel.isHidden = true
            conditionLabel.isHidden = true
            
            mainTempLabelTopConstraint.constant = 10
            mainTempLabelTrailingConstraint.constant = 66
            dayLabelTopConstraint.constant = 25
            layoutIfNeeded()
        
        
    }
    
    
}
