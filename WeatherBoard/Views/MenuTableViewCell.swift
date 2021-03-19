//
//  TableViewCell.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate {
    
    func didPressButton(with cellTitle: String, cellType: MenuTableViewCell.CellType, indexPath: IndexPath)
    func didPressDelete(with cellTitle: String, indexPath: IndexPath)
    
}

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var menuButton: MenuButtonStyle!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var deleteButton: ButtonStyle!
    @IBOutlet weak var stackView: UIStackView!
    
    enum CellType {
        case recent
        case searchResult
    }
    
    var allowDeletion: Bool
    var cellType: CellType?
    
    
    required init?(coder: NSCoder){
        
        self.allowDeletion = true
        super.init(coder: coder)
        
    }
    
    var delegate: MenuTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
        menuLabel.textDropShadow()
        locationIcon.addShadow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.normalTap))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
        
        swipeRight.direction = .right
        swipeLeft.direction = .left
        
        menuButton.addGestureRecognizer(tapGesture)
        menuButton.addGestureRecognizer(swipeLeft)
        menuButton.addGestureRecognizer(swipeRight)
            
        deleteButton.topGradient = "delete_top"
        deleteButton.bottomGradient = "delete_bottom"
        deleteButton.cornerRadius = 12
        deleteButton.isHidden = true
        self.deleteButton.alpha = 0

    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        if
            let collectionView = superview as? UITableView,
            let index = collectionView.indexPath(for: self)
        {
            if let validLabel = menuLabel.text{
                
                delegate?.didPressDelete(with: validLabel, indexPath: index)
            }
        }
    }
    
    
    
    
    @objc func normalTap(_ sender: UIGestureRecognizer) {
        if
            let collectionView = superview as? UITableView,
            let index = collectionView.indexPath(for: self)
        {
            if let validLabel = menuLabel.text{
                
                delegate?.didPressButton(with: validLabel, cellType: cellType!, indexPath: index)
            }
        }

    }
    
    @objc func swipedLeft(_ sender: UIGestureRecognizer){
        
        if allowDeletion{
            if sender.state == .ended {
                print("UIGestureRecognizerStateEnded")
                
                
                
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                    
                    if self.deleteButton.isHidden{
                        self.deleteButton.isHidden = false
                    }
                    self.deleteButton.alpha = 1
                    self.stackView.layoutIfNeeded()
                }

            }else if sender.state == .began {
                print("UIGestureRecognizerStateBegan.")
                //Do Whatever You want on Began of Gesture
            }
        }
    }
    
    @objc func swipedRight(_ sender: UIGestureRecognizer){
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            
            hideButton()
            
            

        }else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
        
    }
    
    func hideButton(){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            
            if !self.deleteButton.isHidden{
                self.deleteButton.isHidden = true
            }
            self.deleteButton.alpha = 0
            self.stackView.layoutIfNeeded()
        }
    }
    
    
    
    
    
    
    
    
    
}
