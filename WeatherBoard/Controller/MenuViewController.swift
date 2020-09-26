//
//  MenuViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 18/08/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import RealmSwift

class MenuViewController: UIViewController, MenuTableViewCellDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchFull: Bool = false
    var locationPressed: Bool = false
    var menuItems: Results<MenuItem>?
    var menuItemPressedCityName: String?
    //var particlesWereShown: Bool?
    
    //realm
    let realm = try! Realm()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMenuItems()
        //print(realm.configuration.fileURL?.absoluteURL)
        
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
    
    func loadMenuItems(){
        
        menuItems = realm.objects(MenuItem.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
        
    }
    
    func didPressButton(with cityName: String, indexPath: IndexPath) {
        menuItemPressedCityName = cityName
        
        do{
            try realm.write{
                realm.delete(menuItems![indexPath.row])
            }
        }catch{
            print(error)
        }
        
        tableView.reloadData()
        //Sends back to main view
        performSegue(withIdentifier: Constants.segues.menuToMain, sender: self)
        
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
                
                
            }else if let validCityName = menuItemPressedCityName{
                
                mainVC.weatherManager.fetchWeather(cityName: validCityName, time: 0)
                
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


//MARK: - TableView Methods

extension MenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if number of menu items lower than 4, return that number of menu items
        
        
        if (menuItems?.count ?? 0 < 4){
            return menuItems?.count ?? 0
        }else{
            return 4
        }
 
        //return menuItems?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MenuTableViewCell
        
        cell.delegate = self
        
        let cellCityName = menuItems?[indexPath.row].cityName
        
        cell.menuLabel.text = cellCityName
        
        //cell.menuButton.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    
    
    
    
    
    
    
}
