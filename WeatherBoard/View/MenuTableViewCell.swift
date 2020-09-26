//
//  TableViewCell.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate {
    
    func didPressButton(with cityName: String, indexPath: IndexPath)
    
    
}

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var menuButton: MenuButton!
    @IBOutlet weak var menuLabel: UILabel!
    
    var delegate: MenuTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
        menuLabel.textDropShadow()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        
        // Configure the view for the selected state
    }
    
    @IBAction func menuButtonPressed(_ sender: MenuButton) {
        if
            let collectionView = superview as? UITableView,
            let index = collectionView.indexPath(for: self)
                {
                if let validLabel = menuLabel.text{
                    delegate?.didPressButton(with: validLabel, indexPath: index)
                }
            }
        
        
        
    }
    
    
    
    
}
