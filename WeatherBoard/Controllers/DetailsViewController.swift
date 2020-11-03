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
    
    func clearWeatherDetails(){
        
        //var count = 0
        
        for cell in tableView.visibleCells {
            
            let detailCell = cell as! DetailsTableViewCell
            
            UIView.animate(withDuration: 0.2){
                detailCell.weatherImageView.isHidden = true
                detailCell.activityIndicator.startAnimating()
                detailCell.mainTempLabel.isHidden = true
                detailCell.highTempLabel.isHidden = true
                detailCell.lowTempLabel.isHidden = true
                detailCell.detailStack.isHidden = true
                detailCell.conditionLabel.isHidden = true
            }
            
        }
        
        
    }
    
    func setWeatherDetails(using weatherModel: WeatherModel){
        
        var count = 0
        
        for day in weatherModel.fiveDayArray{
            
            let indexPath = IndexPath(row: count, section: 0)
            
            if let cell = tableView.cellForRow(at: indexPath) as? DetailsTableViewCell {
                
                
                cell.weatherImageView.isHidden = false
                cell.activityIndicator.stopAnimating()
                cell.mainTempLabel.isHidden = false
                cell.highTempLabel.isHidden = false
                cell.lowTempLabel.isHidden = false
                cell.detailStack.isHidden = false
                cell.conditionLabel.isHidden = false
                
                
                
                cell.weatherImageView.setImage(UIImage(named: "icon_\(day.conditionName)_\(weatherModel.isDayString)"), animated: true)
                
                
                UIView.transition(with: cell.contentView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    if indexPath.row == 0{
                        cell.dayLabel.text = "Today"
                    }else if indexPath.row == 1{
                        cell.dayLabel.text = "Tomorrow"
                    }else{
                        cell.dayLabel.text = day.dayString
                    }
                    cell.mainTempLabel.text = day.tempString
                    cell.highTempLabel.text = day.highTempString
                    cell.lowTempLabel.text = day.lowTempString
                    cell.conditionLabel.text = day.description
                    
                    cell.precipLabel.text = day.precipString
                    cell.windSpeedLabel.text = day.windSpeedString
                    cell.windDirectionLabel.text = day.windDirectionString
                    cell.cloudCoverLabel.text = day.cloudCoverString
                    cell.visibilityLabel.text = day.visibilityString
                    
                    //print(day.visibility)
                    
                }, completion: nil)

                if day.highTemp == day.lowTemp{
                    cell.highTempLabel.isHidden = false
                    cell.lowTempLabel.isHidden = false
                }
            }

            
            
            
            
            count+=1
        }
        
        
        
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
