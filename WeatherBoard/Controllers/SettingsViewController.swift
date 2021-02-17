//
//  SettingsViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 15/02/2021.
//  Copyright © 2021 Justyn Henman. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var unitsPicker: UISegmentedControl!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var defaultLocationPicker: UISegmentedControl!
    @IBOutlet weak var defaultLocationLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.alpha            = 0
        unitsPicker.alpha           = 0
        unitsLabel.alpha            = 0
        defaultLocationLabel.alpha  = 0
        defaultLocationPicker.alpha = 0

        unitsPicker.selectedSegmentIndex = defaults.integer(forKey: C.defaults.units)
        defaultLocationPicker.selectedSegmentIndex = defaults.integer(forKey: C.defaults.defaultToGPS)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlur()
    }
    
    @IBAction func unitsPicker(_ sender: UISegmentedControl) {
        
        let val = sender.selectedSegmentIndex == 1 ? 1 : 0
        defaults.setValue(val, forKey: C.defaults.units)
        
    }
    
    @IBAction func defaultLocationPicker(_ sender: UISegmentedControl) {
        
        let val = sender.selectedSegmentIndex == 1 ? 1 : 0
        defaults.setValue(val, forKey: C.defaults.defaultToGPS)
        
    }
    
    func addBlur(){
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
            let blurEffectView = UIVisualEffectView(effect: nil)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: nil)
            vibrancyView.frame = self.view.bounds
            vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            blurEffectView.tag = 3
            
            view.insertSubview(blurEffectView, at: 0)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            UIView.animate(withDuration: 0.2, delay: 0.05){
                
                blurEffectView.effect = blurEffect
                vibrancyView.effect = vibrancyEffect
                
            }
            UIView.animate(withDuration: 0.2, delay: 0.3){
                self.titleLabel.alpha = 1

            }
            UIView.animate(withDuration: 0.2, delay: 0.5){
                self.unitsLabel.alpha = 1
                

            }
            UIView.animate(withDuration: 0.2, delay: 0.6){
                self.defaultLocationLabel.alpha = 1
                self.unitsPicker.alpha = 1
            }
            UIView.animate(withDuration: 0.2, delay: 0.7){
                self.defaultLocationPicker.alpha = 1
            }
            
        } else {
            view.backgroundColor = .clear
        }
        
    }

    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
