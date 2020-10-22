//
//  MenuViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 18/08/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import RealmSwift

class MenuViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchFull: Bool = false
    var locationPressed: Bool = false
    var locationCellPressed: Bool = false
    var menuItems: Results<MenuItem>?
    var menuItemPressedCityName: String?
    //realm
    let realm = try! Realm()
    
    //MARK: - AppDelegate functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMenuItems()
        //print(realm.configuration.fileURL?.absoluteURL)
        
        //dismisses keyboard when tapped off
        self.hideKeyboardWhenTappedAround()
        
        //forces status bar to be lightt text
        overrideUserInterfaceStyle = .dark

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableMenuCell")
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //searchBar.becomeFirstResponder()
    }
    
    //MARK: - Functions
    
    func loadMenuItems(){
        //loads tableview items from realm, then reloads tableview
        
        
        menuItems = realm.objects(MenuItem.self).sorted(byKeyPath: "date", ascending: false).sorted(byKeyPath: "isCurrentLocation", ascending: false)
        
        
        
        tableView.reloadData()
        
    }
    

    //MARK: - Buttons
    
    //Back button pressed
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        
        //Sends back to main view
        performSegue(withIdentifier: C.segues.menuToMain, sender: self)
        
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        
        do{
            try realm.write{
                let oldLocations = realm.objects(MenuItem.self).filter("isCurrentLocation == %@", true)
                realm.delete(oldLocations)
            }
        }catch{
            print(error)
        }
        locationPressed.toggle()
        //Sends back to main view
        performSegue(withIdentifier: C.segues.menuToMain, sender: self)
        
        
    }
    
    //MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.segues.menuToMain{
            
            let mainVC = segue.destination as! MainViewController
            mainVC.menuOpen.toggle()
            mainVC.toggleHide()
            mainVC.setDetails()

            if locationPressed{
                mainVC.locationManager.requestLocation()
                mainVC.clearDetails()
                
                
            }else if let validCityName = menuItemPressedCityName{
                if locationCellPressed{
                    print("boom shaka")
                    mainVC.weatherManager.fetchWeather(cityName: validCityName, time: 0, doNotSave: true)
                    mainVC.clearDetails()
                    
                    
                }else{
                    mainVC.weatherManager.fetchWeather(cityName: validCityName, time: 0, doNotSave: false)
                    print("boooefhiuagebnogfao")
                    mainVC.clearDetails()
                    
                    
                }
            }else if searchFull{
                mainVC.weatherManager.fetchWeather(cityName: searchBar.text!, time: 0, doNotSave: false)
                mainVC.clearDetails()
                
            }
            
            
            mainVC.addBlur()
            removeParticles(from: mainVC.gradientView)
            
        }
    }
    
}

//MARK: - MenuTableViewCell Delegate methods

extension MenuViewController: MenuTableViewCellDelegate{
    
    func didPressButton(with cityName: String, indexPath: IndexPath) {
        
        
        menuItemPressedCityName = cityName
        
        if menuItems![indexPath.row].isCurrentLocation != true {
            
            
            
            do{
                try realm.write{
                    realm.delete(menuItems![indexPath.row])
                    
                }
            }catch{
                print(error)
            }
        }else{
            locationCellPressed = true
        }
        
        //Sends back to main view
        performSegue(withIdentifier: C.segues.menuToMain, sender: self)
        
    }
}

//MARK: - UISearchBar Delegate Methods

extension MenuViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print(searchBar.text ?? "The moon")
        searchBar.endEditing(true)
        
        if (searchBar.text != ""){
            searchFull = true
            
            performSegue(withIdentifier: C.segues.menuToMain, sender: self)
            
        }else{
            print("No text in ")
        }
        
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


//MARK: - TableView Datasource+Delegate Methods

extension MenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if number of menu items lower than 4, return that number of menu items
        return(menuItems?.count ?? 0 < 4 ? menuItems?.count ?? 0 : 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableMenuCell", for: indexPath) as! MenuTableViewCell
        
        cell.delegate = self
        cell.menuLabel.text = menuItems?[indexPath.row].cityName
        cell.menuButton.bottomGradient = menuItems?[indexPath.row].bottomGradient
        cell.menuButton.topGradient = menuItems?[indexPath.row].topGradient
        
        if menuItems?[indexPath.row].isCurrentLocation != true{
            cell.locationIcon.isHidden = true
            
        }
        
        return cell
    }
    
}
