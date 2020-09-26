//
//  MenuViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 18/08/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchFull: Bool = false
    var locationPressed: Bool = false
    //var particlesWereShown: Bool?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dismisses keyboard when tapped off
        self.hideKeyboardWhenTappedAround()
        
        
        
        //forces status bar to be dark
        overrideUserInterfaceStyle = .dark
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
        
        
    }

    
    //MARK: - Buttons
    
    //Back button pressed
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        
        //Sends back to main view
        performSegue(withIdentifier: Constants.segues.menuToMain, sender: self)
        
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        locationPressed.toggle()
        //Sends back to main view
        performSegue(withIdentifier: Constants.segues.menuToMain, sender: self)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segues.menuToMain{
            
            let mainVC = segue.destination as! MainViewController
            mainVC.menuOpen.toggle()
            mainVC.toggleHide()
            mainVC.setDetails()
            
            
            if locationPressed{
                
                mainVC.locationManager.requestLocation()
                
                
            }else if searchFull{
                mainVC.weatherManager.fetchWeather(cityName: searchBar.text!, time: 0)
                
                
            }
            removeParticles(from: mainVC.gradientView)
            
        }
    }
    
    
    
    
}

extension MenuViewController: UISearchBarDelegate {
    
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



//MARK: - Keyboard dismiss code
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MenuTableViewCell
        
        return cell
    }
    
    
    
    
    
}
