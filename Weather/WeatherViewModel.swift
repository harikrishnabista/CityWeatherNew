//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Hari Bista on 10/14/21.
//

import Foundation

struct WeatherStatDisplayItem {
    var label: String
    var value: String
}

class WeatherViewModel {
    var weatherDetails: WeatherDetails?
    
    var tableDataSource: [WeatherStatDisplayItem] = []
    
    func fetchWeatherDetails(for city: String, completion: @escaping (Bool, String?) -> Void) {
        let apiCaller = DefaultApiCaller<WeatherDetails>()
        
        apiCaller.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "appid", value: apiCaller.appid)
        ]
        
        apiCaller.callApi(endPoint: "/data/2.5/weather") { [weak self] result in
            switch result {
            case .success(let weatherDetails):
                self?.weatherDetails = weatherDetails
                self?.prepareData()
                completion(true, nil)
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func fetchWeatherDetails(latitude: String,
                             longitude: String,
                             completion: @escaping (Bool, String?) -> Void) {
        let apiCaller = DefaultApiCaller<WeatherDetails>()
        
        apiCaller.queryItems = [
            URLQueryItem(name: "lat", value: latitude),
            URLQueryItem(name: "lon", value: longitude),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "appid", value: apiCaller.appid)
        ]
        
        apiCaller.callApi(endPoint: "/data/2.5/weather") { result in
            switch result {
            case .success(let weatherDetails):
                self.weatherDetails = weatherDetails
                self.prepareData()
                completion(true, nil)
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func prepareData(){
        guard let weatherDetails = self.weatherDetails else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "hh:mm a"
        
        // SUNRISE
        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(weatherDetails.sys.sunrise))
        let sunrise = dateFormatter.string(from: sunriseDate)
        let sunriseItem = WeatherStatDisplayItem(label: "SUNRISE", value: sunrise)
        tableDataSource.append(sunriseItem)
        
        // SUNSET
        let sunsetDate = Date(timeIntervalSince1970: TimeInterval(weatherDetails.sys.sunset))
        let sunset = dateFormatter.string(from: sunsetDate)
        let sunsetItem = WeatherStatDisplayItem(label: "SUNSET", value: sunset)
        tableDataSource.append(sunsetItem)
        
        
        // wind
        let windVal = "\(weatherDetails.wind.speed) mph (\(weatherDetails.wind.deg))°"
        let windItem = WeatherStatDisplayItem(label: "WIND", value: windVal)
        tableDataSource.append(windItem)
        
        // pressure
        let pressureItem = WeatherStatDisplayItem(label: "PRESSURE", value: "\(weatherDetails.main.pressure) inHg")
        tableDataSource.append(pressureItem)
        
        // humidity
        let humidityItem = WeatherStatDisplayItem(label: "HUMIDITY", value: "\(weatherDetails.main.humidity) %")
        tableDataSource.append(humidityItem)
        
        // humidity
        let feelslikeItem = WeatherStatDisplayItem(label: "FEELS LIKE", value: "\(weatherDetails.main.feelsLike) °")
        tableDataSource.append(feelslikeItem)
        
    }
    
    
}
