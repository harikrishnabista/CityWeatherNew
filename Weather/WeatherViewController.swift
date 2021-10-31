//
//  WeatherViewController.swift
//  Weather
//
//  Created by Hari Bista on 10/14/21.
//

import UIKit
import Foundation
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var mainStackView: UIStackView!
    var viewModel = WeatherViewModel()
    
    private var locationManager:CLLocationManager?
    private var location: CLLocation?
    
    @IBOutlet weak var currentLocationButton: UIBarButtonItem!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
    }
    
    private func initialSetup(){
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.subscribeUserLocation()
        
        self.searchBar.isHidden = true
        if self.viewModel.weatherDetails == nil {
            self.mainStackView.isHidden = true
        }
        self.searchBar.delegate = self
        
        self.clearInitialData()
    }
    
    private func subscribeUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    private func clearInitialData(){
        self.cityLabel.text = ""
        self.weatherLabel.text = ""
        self.temperatureLabel.text = ""
        self.highTemperatureLabel.text = ""
        self.lowTemperatureLabel.text = ""
    }
    
    @IBAction func searchBarButtonTapped(_ sender: Any) {
        self.mainStackView.isHidden = false
        self.searchBar.isHidden = false
        self.searchBar.becomeFirstResponder()
    }
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        self.searchBar.isHidden = true
        self.loadWeatherDetails(for: self.location)
        self.searchBar.resignFirstResponder()
    }
    
    private func loadWeatherDetails(for city: String){
        // TODO:- show loading UI
        self.viewModel.fetchWeatherDetails(for: city) { success, errorMessage in
            DispatchQueue.main.async {
                // TODO:- hide loading UI
                if success {
                    self.displayWeatherDetailsUI()
                } else {
                    print(errorMessage)
                    // TODO:- show error UI
                    self.displayError()
                }
            }
        }
    }
    
    private func loadWeatherDetails(for location: CLLocation?){
        // TODO:- show loading UI
        guard let location = self.location else { return }
        
        let latitude = "\(location.coordinate.latitude)"
        let longitude = "\(location.coordinate.longitude)"
        
        self.viewModel.fetchWeatherDetails(latitude: latitude,
                                           longitude: longitude) { success, errorMessage in
            DispatchQueue.main.async {
                // TODO:- hide loading UI
                if success {
                    self.displayWeatherDetailsUI()
                } else {
                    print(errorMessage)
                    // TODO:- show error UI
                    self.displayError()
                }
            }
        }
    }
    
    private func displayError(){
        let alert = UIAlertController(title: "Weather search result", message: "City not found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func displayWeatherDetailsUI(){
        guard let weatherDetails = self.viewModel.weatherDetails else { return }
        
        self.mainStackView.isHidden = false
        
        self.cityLabel.text = weatherDetails.name
        self.weatherLabel.text = weatherDetails.weather[0].weatherDescription
        self.temperatureLabel.text = "\(weatherDetails.main.temp) °"
        self.highTemperatureLabel.text = "H:\(weatherDetails.main.tempMax) °"
        self.lowTemperatureLabel.text = "L:\(weatherDetails.main.tempMin) °"
        self.tableView.reloadData()
        
        self.searchBar.isHidden = true
        self.searchBar.resignFirstResponder()
    }

}

extension WeatherViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as? WeatherCell else {
            fatalError()
        }
        cell.display(data: self.viewModel.tableDataSource[indexPath.row])
        return cell
    }
}

extension WeatherViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if self.location == nil {
                self.location = location
                self.loadWeatherDetails(for: location)
            }
        }
    }
}

extension WeatherViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let city = searchBar.text {
            self.loadWeatherDetails(for: city)
        }
    }
}
