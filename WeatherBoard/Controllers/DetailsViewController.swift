//
//  DetailsViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 09/10/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedCellIndexPath: IndexPath?
    
    let selectedHeight: CGFloat = 300
    let deselectedHeight: CGFloat = 70
    
    var firstLaunch: Bool = true
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "DetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableDetailsCell")
        tableView.beginUpdates()
        tableView.endUpdates()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        firstLaunch = false
        
    }
    
}

extension DetailsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableDetailsCell", for: indexPath) as! DetailsTableViewCell
        
        if indexPath.row == 0{
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            
            
            
            cell.setBig()
            
        }
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.row == 0 && firstLaunch{
                
                return selectedHeight
                
            }
        
        
        if selectedCellIndexPath == indexPath {
                return selectedHeight
        }else{
            
            return deselectedHeight
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
        } else {
            selectedCellIndexPath = indexPath
        }

        
        
        tableView.beginUpdates()
        tableView.endUpdates()

        if selectedCellIndexPath != nil {
                // This ensures, that the cell is fully visible once expanded
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if tableView.cellForRow(at: indexPath)!.isSelected{
            return nil
        }else{
            return indexPath
        }
        
    }
    
    
}
