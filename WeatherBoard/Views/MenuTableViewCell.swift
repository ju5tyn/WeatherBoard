//
//  TableViewCell.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 25/09/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate {
    
    func didPressButton(_ menuTableViewCell: MenuTableViewCell, with cellTitle: String, cellType: MenuTableViewCell.CellType, indexPath: IndexPath)
    func didPressDelete(_ menuTableViewCell: MenuTableViewCell, with cellTitle: String, indexPath: IndexPath)
    func didShowDeleteButton(_ menuTableViewCell: MenuTableViewCell)
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
        deleteButton.imageView?.addShadow()
        
        setupGestures()
            
        deleteButton.topGradient = "delete_top"
        deleteButton.bottomGradient = "delete_bottom"
        deleteButton.cornerRadius = 12
        deleteButton.isHidden = true
        self.deleteButton.alpha = 0

    }
    
    
    func setupGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.normalTap))

        menuButton.addGestureRecognizer(tapGesture)
        
        if allowDeletion{
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
            
            
            swipeRight.direction = .right
            swipeLeft.direction = .left
            
            menuButton.addGestureRecognizer(swipeLeft)
            menuButton.addGestureRecognizer(swipeRight)
        }
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
                
                delegate?.didPressDelete(self, with: validLabel, indexPath: index)
            }
        }
    }
    
    
    
    
    @objc func normalTap(_ sender: UIGestureRecognizer) {
        if
            let collectionView = superview as? UITableView,
            let index = collectionView.indexPath(for: self)
        {
            if let validLabel = menuLabel.text{
                delegate?.didPressButton(self, with: validLabel, cellType: cellType!, indexPath: index)
            }
        }

    }
    
    @objc func swipedLeft(_ sender: UIGestureRecognizer){
        if allowDeletion{
            if sender.state == .ended {
                self.delegate?.didShowDeleteButton(self)
             }
        }
    }
    
    @objc func swipedRight(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            hideDeleteButton()
        }
        
    }
    
    func showDeleteButton(){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            
            if self.deleteButton.isHidden{
                self.deleteButton.isHidden = false
            }
            self.deleteButton.alpha = 1
            self.stackView.layoutIfNeeded()
        }
        
    }
    
    func hideDeleteButton(){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            
            if !self.deleteButton.isHidden{
                self.deleteButton.isHidden = true
            }
            self.deleteButton.alpha = 0
            self.stackView.layoutIfNeeded()
        }
    }
    
    
    
    
    
    
    
    
    
}
