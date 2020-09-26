//
//  TableViewCell.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var menuButton: MenuButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
        //menuButton.titleLabel?.textColor = UIColor.white
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        
        // Configure the view for the selected state
    }
    
    
    
}
