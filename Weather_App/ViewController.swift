//
//  ViewController.swift
//  Weather_App
//
//  Created by Siarhei Bardouski on 3/12/20.
//  Copyright © 2020 Siarhei Bardouski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherNowLabel: UILabel!
    @IBOutlet weak var dailyWeatherTableView: UITableView!
    
    var responseModel: WeatherForecast?
    var degreeSymbol = "º"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentWeatherRequest()
        dailyWeatherTableView.delegate = self
        dailyWeatherTableView.dataSource = self
        reloadView()
        dailyWeatherTableView.tableFooterView = UIView()
        //self.dailyWeatherTableView.automatic
    }
    
    func currentWeatherRequest() {
    let session = URLSession.shared
        let weatherURL = URL(string: "https://api.darksky.net/forecast/1dcbd502506839effc15e04a5ecb687f/52.4345,30.9754?units=si&lang=ru")!
    let dataTask = session.dataTask(with: weatherURL) { (data: Data?,response: URLResponse?,error: Error?) in
            if let error = error {
                print("Error:\n\(error)")
                
            } else {
                if let jsonData = data {
                 
                    do {
                        let dataString = String(data: jsonData, encoding: String.Encoding.utf8)
              print("Daily weather data:\n\(dataString!)")
                    let decoder = JSONDecoder()
                        
                        self.responseModel = try decoder.decode(WeatherForecast.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            self.cityNameLabel.text = "Гомель"
                            self.weatherNowLabel.text = (self.responseModel?.currently.summary.self).map { $0.rawValue }
                            self.dailyWeatherTableView.reloadData()
                            self.reloadView()
                        }
                        
                    } catch let error {
                      print("Error: \(error)")
                    }
                }else {
                print("Error: did not receive data")
                    
            }
            }
        }
        dataTask.resume()
        
    }
    
    public func reloadView(){
        
        let temperatureNow = responseModel?.currently
        if let currentTemp = temperatureNow?.temperature{
            self.temperatureLabel.text = "\(String(describing: Int(currentTemp)))\(degreeSymbol)"
        } else {
            self.temperatureLabel.text = "No data"
        }
    }

    public    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseModel?.daily.data[1...7].count ?? 7
    }
    
    
    
   public     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "FullDayWeatherCell", for: indexPath) as? DailyWeatherViewCell else { return UITableViewCell() }
   
    let dateList = responseModel?.daily
    if let nowDate = dateList?.data[indexPath.row].time {
    let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: (TimeInterval(nowDate)))
        dateFormatter.locale = Locale(identifier: "ru_UK")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        cell.dayLabel.text = dateFormatter.string(from: date + 86400)} else {
        cell.dayLabel.text = "No data"
    }
    
    let weatherList = responseModel?.daily.data[indexPath.row + 1]
    if let dailyWeather = weatherList?.summary {
        cell.weatherLabel.text =  dailyWeather
        print(dailyWeather)
    } else {
        cell.weatherLabel.text = "No data"
    }
    
    let listArray = responseModel?.daily.data[indexPath.row + 1]
    if let minTemperature = listArray?.temperatureLow {
        cell.minTempLabel.text = "\(String(describing:Int( minTemperature)))\(degreeSymbol)"
    } else {
        cell.minTempLabel.text = "No data"
    }
    
    if let maxTemperature = listArray?.temperatureHigh {
           cell.maxTempLabel.text = "\(String(describing: Int( maxTemperature)))\(degreeSymbol)"
       } else {
           cell.maxTempLabel.text = "No data"
       }
    
    
    
    return cell
        
    }
    
 private  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableView.automaticDimension
    }

}
