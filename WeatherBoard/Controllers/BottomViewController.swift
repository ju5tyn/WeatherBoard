//
//  BottomViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 05/05/2021.
//  Copyright © 2021 Justyn Henman. All rights reserved.
//

import UIKit

class BottomViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var paperImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = .clear
        //self.view.alpha = 0.3
        
        paperImage.image = UIImage(named: "paper-texture")!.resizableImage(withCapInsets: .zero,
                                                                           resizingMode: .tile)
        //paperImage.layer.cornerRadius = 10
        //backgroundView.layer.cornerRadius = 10
        
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        backgroundView.layer.shadowRadius = 2
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
