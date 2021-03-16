//
//  MenuViewController.swift
//  WeatherBoard
//
//  Created by Justyn Henman on 18/08/2020.
//  Copyright © 2020 Justyn Henman. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import GoogleMobileAds

class MenuViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bottomButtons: [UIButton]!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var adLabel: UILabel!
    @IBOutlet weak var adBackground: UIView!
    @IBOutlet weak var adSpinner: UIActivityIndicatorView!
    @IBOutlet weak var recentsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    
    var searchFull: Bool = false
    var locationPressed: Bool = false
    var locationCellPressed: Bool = false
    
    var menuItems: Results<MenuItem>?
    var menuItemPressedCityName: String?

    let realm = try! Realm()
    
    var shouldReload = false
 
    //MARK: - AppDelegate functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAlpha()
        loadMenuItems()
        hideKeyboardWhenTappedAround()
        
        overrideUserInterfaceStyle = .dark
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        bannerView.delegate = self
        
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableMenuCell")
        tableView.reloadData()
        
        recentsLabel.isHidden = false
        
        bannerView.adUnitID = Keys.admobUnitID
        bannerView.rootViewController = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if false{
            loadBannerAd()
        }else{
            
        }

        for button in bottomButtons{
            UIView.animate(withDuration: 0.5, delay: 0){
                button.alpha = 1
            }
        }
    }
    
    
    
    
    
    
    
    
    
    //MARK: - Functions
    

    func setAlpha(){
        
        for btn in bottomButtons{
            btn.alpha = 0
        }
        adBackground.alpha = 0
        adLabel.alpha = 0
        //bannerView.alpha = 0
    }
    
    func loadBannerAd() {

        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerView.frame.width)
        bannerView.load(GADRequest())

        UIView.animate(withDuration: 0.5, delay: 0){
            self.adBackground.alpha = 1
            self.adLabel.alpha = 1
        }
    }
    

    func loadMenuItems(){
        //loads tableview items from realm, then reloads tableview
        menuItems = realm.objects(MenuItem.self).sorted(byKeyPath: "date", ascending: false).sorted(byKeyPath: "isCurrentLocation", ascending: false)
        tableView.reloadData()
    }
    
    
    private func exitMenu(_ segue: UIStoryboardSegue) {
        
        backButton.isEnabled = true
        
        if segue.identifier == C.segues.menuToMain{
            
            let mainVC = segue.destination as! MainViewController
            
            mainVC.menuOpen.toggle()
            //mainVC.mainView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                mainVC.mainView.alpha = 1
            }
            if locationPressed{
                mainVC.locationManager.requestLocation()
                mainVC.clearDetails()
                
            }else if let validCityName = menuItemPressedCityName{
                mainVC.weatherManager.fetchWeather(cityName: validCityName, doNotSave: locationCellPressed)
                mainVC.clearDetails()
            }else if searchFull{
                mainVC.weatherManager.fetchWeather(cityName: searchBar.text!, doNotSave: false)
                mainVC.clearDetails()
                
            }else if shouldReload{
                
                mainVC.weatherManager.fetchWeather(cityName: (mainVC.weatherModel?.locationName)!, doNotSave: true)
                mainVC.clearDetails()
                
            }else{
                mainVC.setDetails()
            }
            
            mainVC.updateBlur()
        }
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
    
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: C.segues.menuToAbout, sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: C.segues.menuToSettings, sender: self)
        shouldReload = true
    }
    
    
    
    
    
    //MARK: - Prepare for segue
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier{
            case C.segues.menuToAbout:
                _ = segue.destination as! AboutViewController
            case C.segues.menuToMain:
                exitMenu(segue)
            case C.segues.menuToSettings:
                _ = segue.destination as! SettingsViewController
            case .none:
                break
            case .some(_):
                break
        }
        
        
        
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {

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
    
    func didPressDelete(with cityName: String, indexPath: IndexPath) {
        
        
        do{
            try realm.write{
                realm.delete(menuItems![indexPath.row])
            }
        }catch{
            print(error)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableMenuCell", for: indexPath) as! MenuTableViewCell
        
        cell.menuButton.setNeedsDisplay()
        
        
        UIView.animate(withDuration: 0.3) {
            self.loadMenuItems()
        }
        
        //self.tableView.reloadData(with: .middle)
        
       // var count = 0
        
        for cell in tableView.visibleCells as! [MenuTableViewCell] {
            cell.menuButton.setNeedsDisplay()
            cell.hideButton()
            UIView.transition(with: cell, duration: 0.4, options: .transitionFlipFromTop, animations: {}, completion: nil)
  
        }
        
//        for cell in tableView.visibleCells as! [MenuTableViewCell] {
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 1, delay: TimeInterval(count)) {
//                    UIView.transition(with: cell, duration: 0.4, options: .transitionFlipFromTop, animations: {cell.isHidden = false}, completion: nil)
//                }
//
//                count+=1
//            }
//
//
//        }
        
//        UIView.transition(with: tableView, duration: 0.4, options: .transitionFlipFromRight, animations: {self.tableView.reloadData()}, completion: nil)
//
        

        tableView.layoutSubviews()
        
    }
}

extension UITableView {
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}


//MARK: - UISearchBar Delegate Methods

extension MenuViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print(searchBar.text ?? "The moon")
        searchBar.endEditing(true)
        
        if (searchBar.text != ""){
            searchFull = true
            //checks to see if search text is valid
            CLGeocoder().geocodeAddressString(searchBar.text!) { (placemark, error) in
                if let e = error{
                    self.searchBar.text = ""
                    self.searchBar.placeholder = "Invalid Location"
                    print(e.localizedDescription)
                }else{
                    self.performSegue(withIdentifier: C.segues.menuToMain, sender: self)
                }
            }

        }else{
            print("No text in ")
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search for a location"
    }
    
}


//MARK: - GADBannerView Delegate
extension MenuViewController: GADBannerViewDelegate{
    

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            bannerView.alpha = 1
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        adSpinner.stopAnimating()
        adLabel.text = "error loading ad".uppercased()
    }
    
    
}


//MARK: - TableView Datasource+Delegate Methods

extension MenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if number of menu items lower than 4, return that number of menu items
        if menuItems?.count == 0{
            recentsLabel.isHidden = true
        }
        
        return(menuItems?.count ?? 0 < 4 ? menuItems?.count ?? 0 : 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableMenuCell", for: indexPath) as! MenuTableViewCell
        
        cell.deleteButton.isHidden = true
        
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
