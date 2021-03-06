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
    
    func menuViewControllerDidSearchResultCellPressed(_ menuViewController: MenuViewController, lat: Double, lon: Double)
    
    func menuViewControllerDidRecentCellPressed(_ menuViewController: MenuViewController, lat: Double, lon: Double, isLocation: Bool)
    
    func menuViewControllerDidMakeRequest(_ menuViewController: MenuViewController)
    
    func menuViewControllerDidDismissWithNoRequest(_ menuViewController: MenuViewController)
    
    func menuViewControllerDidRequestRefresh(_ menuViewController: MenuViewController)
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bottomButtons: [UIButton]!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    
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

    let realm = try! Realm()
    
    var shouldReload = false

    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var delegate: MenuViewControllerDelegate?
    
    //MARK: - AppDelegate functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///localisable strings init
        settingsButton.titleLabel?.text = NSLocalizedString("MENU_BUTTON_SETTINGS", comment: "Settings button text")
        aboutButton.titleLabel?.text = NSLocalizedString("MENU_BUTTON_ABOUT", comment: "Settings button text")
        recentsLabel.text = NSLocalizedString("MENU_TEXT_RECENTS", comment: "Label showing recents below")
        adLabel.text = NSLocalizedString("MENU_TEXT_AD_SUCCESS", comment: "Label shown above ad")
        
        
        
        recentsLabel.isHidden = false
        recentsLabel.morphingEffect = .scale
        setAlpha()
        loadMenuItems()
        hideKeyboardWhenTappedAround()
        
        cleanRealm()
        
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
    
    func cleanRealm(){ //cleans realm is traces of broken results
        for item in menuItems!{
            if (item.lat == 0.0 || item.cityName == nil){
                do{
                    try realm.write{ realm.delete(item) }
                }catch{
                    print(error)
                }
            }
        }
    }
    
    

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
        }
    }
    
    
    
    //MARK: - Buttons
    
    //Back button pressed
    @IBAction func backButtonPressed(_ sender: UIButton) {
        //Sends back to main view
        if shouldReload{
            delegate?.menuViewControllerDidRequestRefresh(self)
        }else{
            delegate?.menuViewControllerDidDismissWithNoRequest(self)
        }
        
        
        //performSegue(withIdentifier: C.segues.menuToMain, sender: self)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        delegate?.menuViewControllerDidRequestLocation(self)
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: C.segues.menuToAbout, sender: self)
        tableView.hideDeleteButtons()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: C.segues.menuToSettings, sender: self)
        tableView.hideDeleteButtons()
    }
    
    
    
    
    
    //MARK: - Prepare for segue
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier{
            case C.segues.menuToAbout:
                _ = segue.destination as! AboutViewController
            case C.segues.menuToSettings:
                let settingsVC = segue.destination as! SettingsViewController
                settingsVC.delegate = self
            default:
                break
        }
        
        
        
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {

    }
    

    
}



//MARK: - MenuTableViewCell Delegate methods

extension MenuViewController: MenuTableViewCellDelegate{
    

    func didPressButton(_ menuTableViewCell: MenuTableViewCell, with cellTitle: String, cellType:MenuTableViewCell.CellType, indexPath: IndexPath) {
          
        switch cellType{
            case .recent:
                let item = menuItems![indexPath.row]
                self.delegate?.menuViewControllerDidRecentCellPressed(self, lat: item.lat, lon: item.lon, isLocation: item.isCurrentLocation)
                
                if !item.isCurrentLocation{
                    do{
                        try realm.write{ realm.delete(item) }
                    }catch{
                        print(error)
                    }
                }

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
                    self.delegate?.menuViewControllerDidSearchResultCellPressed(self,
                                                                       lat: coordinate.latitude,
                                                                       lon: coordinate.longitude)
                }
        }
    }
    
    func didPressDelete(_ menuTableViewCell: MenuTableViewCell, with cellTitle: String, indexPath: IndexPath) {
        
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
    
    func didShowDeleteButton(_ menuTableViewCell: MenuTableViewCell) {
        
        for cell in tableView.visibleCells as! [MenuTableViewCell]{
            cell.hideDeleteButton()
            cell.menuButton.setNeedsDisplay()
        }
        
        menuTableViewCell.showDeleteButton()
        
    }
}

extension UITableView {

    func reloadData(shouldAnimate: Bool){
        self.reloadData()
        
        if shouldAnimate{
            for cell in self.visibleCells as! [MenuTableViewCell] {
                cell.menuButton.setNeedsDisplay()
                cell.hideDeleteButton()
                UIView.transition(with: cell, duration: 0.4, options: .transitionFlipFromTop, animations: {}, completion: nil)
            }
        }
        
    }
    
    func hideDeleteButtons(){
        
        for cell in self.visibleCells as! [MenuTableViewCell]{
            cell.hideDeleteButton()
            cell.menuButton.setNeedsDisplay()
        }
        
    }
    
}


//MARK: - UISearchBar Delegate Methods

extension MenuViewController: UISearchBarDelegate {
    
    
    //🔍CLICKED
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchResults.count > 0 {
            
            let result = searchResults[0]
            let searchRequest = MKLocalSearch.Request(completion: result)
            
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                    return
                }
                guard (response?.mapItems[0].name) != nil else {
                    return
                }
                self.delegate?.menuViewControllerDidSearchResultCellPressed(self,
                                                                   lat: coordinate.latitude,
                                                                   lon: coordinate.longitude)
            }
            
            
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancelcllilcked")
        recentsLabel.text = NSLocalizedString("MENU_TEXT_RECENTS", comment: "text indicating recents shown")
        if (searchBar.text != "" && searchBar.searchTextField.isEditing) {
            tableView.reloadData(shouldAnimate: true)
        }
    }

    
    //SEARCH BAR BEGIN EDITING
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.hideDeleteButtons()
        searchBar.placeholder = "Search for a location"
        
        print("didbeginediting")
        if searchBar.text != "" {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.querySearch(_:)), object: searchBar)
            perform(#selector(self.querySearch(_:)), with: searchBar, afterDelay: 0.2)
        }
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        recentsLabel.text = NSLocalizedString("MENU_TEXT_RECENTS", comment: "text indicating recents shown")
        if (searchBar.text != "") {
            tableView.reloadData(shouldAnimate: true)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.hideDeleteButtons()
        if searchText != "" {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.querySearch(_:)), object: searchBar)
            perform(#selector(self.querySearch(_:)), with: searchBar, afterDelay: 0.5)
        }else{
            recentsLabel.text = "Recents"
            tableView.reloadData(shouldAnimate: true)
        }
    }

    @objc func querySearch(_ searchBar: UISearchBar) {
        recentsLabel.text = NSLocalizedString("MENU_TEXT_RESULTS", comment: "text indicating results shown")
        
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
            recentsLabel.text = NSLocalizedString("MENU_TEXT_INTERNET_ERROR", comment: "internet error text")
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
        adLabel.text = NSLocalizedString("MENU_TEXT_AD_ERROR", comment: "ad error text").uppercased()
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


extension MenuViewController: SettingsViewControllerDelegate {
    
    func didChangeUnits() {
        shouldReload = true
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
