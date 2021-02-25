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
    @IBOutlet weak var menuButton: MenuButtonStyle!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var deleteButton: ButtonStyle!
    
    
    var delegate: MenuTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
        menuLabel.textDropShadow()
        locationIcon.addShadow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.normalTap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.longTap))
        
        menuButton.addGestureRecognizer(tapGesture)
        //menuButton.addGestureRecognizer(longGesture)
        menuButton.addGestureRecognizer(swipeGesture)
        
        deleteButton.topGradient = "delete_top"
        deleteButton.bottomGradient = "delete_bottom"
        deleteButton.cornerRadius = 12
        //deleteButton.isHidden = true

    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func normalTap(_ sender: UIGestureRecognizer) {
        if
            let collectionView = superview as? UITableView,
            let index = collectionView.indexPath(for: self)
        {
            if let validLabel = menuLabel.text{
                
                delegate?.didPressButton(with: validLabel, indexPath: index)
            }
        }

    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        
        if sender.state == .ended {
                print("UIGestureRecognizerStateEnded")
                //Do Whatever You want on End of Gesture
            }
            else if sender.state == .began {
                print("UIGestureRecognizerStateBegan.")
                //Do Whatever You want on Began of Gesture
            }
        
    }
    
    @objc func swipeTap(_ sender: UIGestureRecognizer){
        
        print("epic")
        
    }
    
    
    
    
    
    
    
    
}
