//
//  ForecastClient.swift
//  BysGameStats
//
//  Created by James Tench on 11/14/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import Foundation
import UIKit

struct ForecastClient {
    
    let forecastAPIKey = "86ef23332530196a8da54e47e99e1b36"
    let forecastBaseURL : NSURL?
    init() {
        forecastBaseURL = NSURL(string: "https://api.forecast.io/forecast/\(forecastAPIKey)/")
    }
    
    func getForecast(lat: Double, long: Double, completion: (CurrentWeather?) -> Void) {
        if let searchURL = NSURL(string: "\(lat),\(long)", relativeToURL: forecastBaseURL) {
            let request = NSURLRequest(URL: searchURL)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { result, response, downloadError in
                if let _ = downloadError {
                    completion(nil)
                } else {
                    if let data = result {
                        let parsedResult: AnyObject?
                        do {
                            try parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject]
                        } catch {
                            // no need to pass error weather will not make or break the app
                            completion(nil)
                            return
                        }
                        
                        if let weatherDictionary = parsedResult as? [String: AnyObject] {
                            if let currentWeatherDictionary = weatherDictionary["currently"] as? [String: AnyObject] {
                                let currentWeather = CurrentWeather(weatherDictionary: currentWeatherDictionary)
                                completion(currentWeather)
                            }
                        }
                    }
                }
            }
            task.resume()
        } else {
            print("Could not construct a valid URL")
        }
    }
}