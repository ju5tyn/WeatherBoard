//
//  MenuViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 18/08/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchFull: Bool = false
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        //Search bar delegate
        searchBar.delegate = self
        
        
    }

    
    //MARK: - Buttons
    
    //Back button pressed
    @IBAction func backButtonPressed(_ sender: UIButton) {
        //Sends back to main view
        performSegue(withIdentifier: Constants.segues.menuToMain, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.menuToMain{
            
            let mainVC = segue.destination as! MainViewController
            mainVC.menuOpen.toggle()
            mainVC.toggleHide()
            mainVC.setDetails()
            
            
            if searchFull{
                mainVC.weatherManager.fetchWeather(cityName: searchBar.text!, time: 0)
                
                //removeParticles(view: mainVC.view)
                //hideParticles(view: mainVC.view)
                //temporary
                showParticles(view: view)
                //setParticles(baseView: mainVC.gradientView, emitterNode: mainVC.emitterNode)
                
            }else{
                
                showParticles(view: view)
                
            }
            
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print(searchBar.text ?? "The moon")
        searchBar.endEditing(true)
        
        if (searchBar.text != ""){
            searchFull = true
            
            performSegue(withIdentifier: Constants.segues.menuToMain, sender: self)
            
        }else{
            print("error no text boooo")
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    
}
