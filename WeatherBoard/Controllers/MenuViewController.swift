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
import MapKit
import LTMorphingLabel

protocol MenuViewControllerDelegate {
    
    func menuViewControllerDidEnd(_ menuViewController: MenuViewController)
    
    func menuViewControllerDidRequestLocation(_ menuViewController: MenuViewController)
    
    func menuViewControllerDidSearchResultPressed(_ menuViewController: MenuViewController,
                                              lat: Double,
                                              lon: Double)
    
    func menuViewControllerDidRecentPressed(_ menuViewController: MenuViewController, lat: Double, lon: Double)
    
    func menuViewControllerDidRequestReload(_ menuViewController: MenuViewController)
    
    func menuViewControllerDidDismissWithNoRequest(_ menuViewController: MenuViewController)
    
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bottomButtons: [UIButton]!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var adLabel: UILabel!
    @IBOutlet weak var adBackground: UIView!
    @IBOutlet weak var adSpinner: UIActivityIndicatorView!
    @IBOutlet weak var recentsLabel: LTMorphingLabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    
    var searchFull: Bool = false
    var locationPressed: Bool = false
    var locationCellPressed: Bool = false
    
    var menuItems: Results<MenuItem>?
    var menuItemPressedCityName: String?
    var menuItemPressedLat: Double?
    var menuItemPressedLon: Double?
    

    let realm = try! Realm()
    
    var shouldReload = false

    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var delegate: MenuViewControllerDelegate?
    
    //MARK: - AppDelegate functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recentsLabel.isHidden = false
        recentsLabel.morphingEffect = .scale
        setAlpha()
        loadMenuItems()
        hideKeyboardWhenTappedAround()
        
        overrideUserInterfaceStyle = .dark
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        bannerView.delegate = self
        searchCompleter.delegate = self
        
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableMenuCell")
        tableView.reloadData()
        
        
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
        
        //backButton.isEnabled = true
        delegate?.menuViewControllerDidEnd(self)
        
        if segue.identifier == C.segues.menuToMain{
            
            let mainVC = segue.destination as! MainViewController
            
//            mainVC.menuOpen.toggle()
//            //mainVC.mainView.isHidden = false
//            UIView.animate(withDuration: 0.5) {
//                mainVC.mainView.alpha = 1
//            }
//
//            if locationPressed{
//
//                delegate?.menuViewControllerDidRequestLocation(self)
//
//            }else if (menuItemPressedLat != nil && menuItemPressedLon != nil){
//                print("USED LOCATION CELL")
//                mainVC.weatherManager.fetchWeather(latitude: menuItemPressedLat!, longitude: menuItemPressedLon!, doNotSave: locationCellPressed)
//            }else if let validCityName = menuItemPressedCityName{
//                print("USED CITY NAME")
//                mainVC.weatherManager.fetchWeather(cityName: validCityName, doNotSave: locationCellPressed)
//                mainVC.clearDetails()
//            }else if searchFull{
//                print("USED SEARCH SHIT")
//                mainVC.weatherManager.fetchWeather(cityName: searchBar.text!, doNotSave: false)
//                mainVC.clearDetails()
//
//            }else if shouldReload{
//                print("USED SHOULOD RELOAD")
//                mainVC.weatherManager.fetchWeather(cityName: (mainVC.weatherModel?.locationName)!, doNotSave: true)
//                mainVC.clearDetails()
//
//            }else{
//
//                mainVC.changeDetails()
//            }
//
//            print("USED SHIT SEGUE INSTEAD OF CHAD DELEGETAE")
//            mainVC.updateBlur()
        }
    }
    
    
    
    //MARK: - Buttons
    
    //Back button pressed
    @IBAction func backButtonPressed(_ sender: UIButton) {
        //Sends back to main view
        delegate?.menuViewControllerDidDismissWithNoRequest(self)
        //performSegue(withIdentifier: C.segues.menuToMain, sender: self)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        delegate?.menuViewControllerDidRequestLocation(self)
        //self.dismiss(animated: true, completion: nil)
        
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
            case C.segues.menuToSettings:
                _ = segue.destination as! SettingsViewController
            case C.segues.menuToMain:
                exitMenu(segue)
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
    

    func didPressButton(with cellTitle: String, cellType:MenuTableViewCell.CellType, indexPath: IndexPath) {
          
        switch cellType{
            case .recent:
                let item = menuItems![indexPath.row]
                
                if menuItems?[indexPath.row].isCurrentLocation == true {
//                    locationCellPressed = true
                    //DO SOMETHING WITH THE VALUE SUCH AS DONOTSAVE
                    
                }else{

                    self.delegate?.menuViewControllerDidRecentPressed(self, lat: item.lat, lon: item.lon)
                    do{
                        try realm.write{ realm.delete(item) }
                    }catch{
                        print(error)
                    }
                }
                
                
//                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: C.segues.menuToMain, sender: self)
//                }
                
                
            case .searchResult:
                
                let result = searchResults[indexPath.row]
                let searchRequest = MKLocalSearch.Request(completion: result)
                
                let search = MKLocalSearch(request: searchRequest)
                search.start { (response, error) in
                    guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                        return
                    }
                    guard (response?.mapItems[0].name) != nil else {
                        return
                    }
                    self.delegate?.menuViewControllerDidSearchResultPressed(self,
                                                                       lat: coordinate.latitude,
                                                                       lon: coordinate.longitude)
                }
        }
    }
    
    func didPressDelete(with cellTitle: String, indexPath: IndexPath) {
        
        do{
            try realm.write{
                realm.delete(menuItems![indexPath.row])
            }
        }catch{
            print(error)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableMenuCell", for: indexPath) as! MenuTableViewCell
        
        cell.menuButton.setNeedsDisplay()
        
        self.loadMenuItems()
        
        tableView.reloadData(shouldAnimate: true)
        tableView.layoutSubviews()
        
    }
}

extension UITableView {

    func reloadData(shouldAnimate: Bool){
        self.reloadData()
        
        if shouldAnimate{
            for cell in self.visibleCells as! [MenuTableViewCell] {
                cell.menuButton.setNeedsDisplay()
                cell.hideButton()
                UIView.transition(with: cell, duration: 0.4, options: .transitionFlipFromTop, animations: {}, completion: nil)
            }
        }
        
    }
}


//MARK: - UISearchBar Delegate Methods

extension MenuViewController: UISearchBarDelegate {
    
    
    //🔍CLICKED
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        
        
//        print(searchBar.text ?? "The moon")
//        searchBar.endEditing(true)
//
        //dismissKeyboard()
//        if (searchBar.text != ""){
//            searchFull = true
//            //checks to see if search text is valid
//            CLGeocoder().geocodeAddressString(searchBar.text!) { (placemark, error) in
//                if let e = error{
//                    self.searchBar.text = ""
//                    self.searchBar.placeholder = "Invalid Location"
//                    print(e.localizedDescription)
//                }else{
//                    self.performSegue(withIdentifier: C.segues.menuToMain, sender: self)
//                }
//            }
//
//        }else{
//            print("No text in ")
//        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancelcllilcked")
        recentsLabel.text = "Recents"
        if (searchBar.text != "" && searchBar.searchTextField.isEditing) {
            tableView.reloadData(shouldAnimate: true)
        }
    }

    
    //SEARCH BAR BEGIN EDITING
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search for a location"
        
        print("didbeginediting")
        if searchBar.text != "" {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.querySearch(_:)), object: searchBar)
            perform(#selector(self.querySearch(_:)), with: searchBar, afterDelay: 0.2)
        }
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        recentsLabel.text = "Recents"
        if (searchBar.text != "") {
            tableView.reloadData(shouldAnimate: true)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.querySearch(_:)), object: searchBar)
            perform(#selector(self.querySearch(_:)), with: searchBar, afterDelay: 0.5)
        }else{
            recentsLabel.text = "Recents"
            tableView.reloadData(shouldAnimate: true)
        }
    }

    @objc func querySearch(_ searchBar: UISearchBar) {
        recentsLabel.text = "Results"
        
        if searchCompleter.queryFragment != searchBar.text{
            searchCompleter.queryFragment = searchBar.text!
        }else{
            tableView.reloadData(shouldAnimate: true)
        }
        
        
    }
    
    
    
    
}

//MARK: - MapKit Search Completer Delegate
extension MenuViewController: MKLocalSearchCompleterDelegate{
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        completer.resultTypes = .address
        completer.pointOfInterestFilter = .none
        searchResults = completer.results.filter{ result in
            if result.title.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                return false
            }
            if result.subtitle.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                return false
            }
            return true
        } //filter out some places from search
        
        tableView.reloadData(shouldAnimate: true)
        tableView.layoutSubviews()
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
        if searchBar.text != ""{
            recentsLabel.text = "No internet connection"
        }
        
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
        var count = 0
        
        if (searchBar.searchTextField.isEditing && searchBar.text != ""){
            count = searchResults.count < 4 ? searchResults.count : 4
        } else {
            count = menuItems?.count ?? 0 < 4 ? menuItems?.count ?? 0 : 4
        }
        if menuItems?.count == 0{
            recentsLabel.isHidden = true
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableMenuCell", for: indexPath) as! MenuTableViewCell
        
        cell.delegate = self
        
        if ((searchBar.searchTextField.isEditing || searchBar.searchTextField.isFocused) && searchBar.text != ""){

            let searchResult = searchResults[indexPath.row]
            
            cell.menuLabel.text = searchResult.title
            cell.menuButton.bottomGradient = "hill_menu_bottom"
            cell.menuButton.topGradient = "hill_menu_top"
            cell.locationIcon.isHidden = true
            cell.allowDeletion = false
            cell.cellType = .searchResult
            
        }else{
            
            
            cell.menuLabel.text = menuItems?[indexPath.row].cityName
            cell.menuButton.bottomGradient = menuItems?[indexPath.row].bottomGradient
            cell.menuButton.topGradient = menuItems?[indexPath.row].topGradient
            
            if menuItems?[indexPath.row].isCurrentLocation != true{
                cell.locationIcon.isHidden = true
            }else{
                cell.locationIcon.isHidden = false
            }
            cell.allowDeletion = true
            cell.cellType = .recent
            
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
