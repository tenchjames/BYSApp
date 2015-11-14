//
//  CurrentWeather.swift
//  BysGameStats
//
//  Created by James Tench on 11/13/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit


struct CurrentWeather {
    let temperature: Int?
    let humidity: Int?
    let precipProbability: Int?
    let summary: String?
    
    init(weatherDictionary: [String: AnyObject]) {
        temperature = weatherDictionary["temperature"] as? Int
        if let humidityDouble = weatherDictionary["humidity"] as? Double {
            humidity = Int(humidityDouble * 100)
        } else {
            humidity = nil
        }
        
        if let precipProbabilityDouble = weatherDictionary["precipProbability"] as? Double {
            precipProbability = Int(precipProbabilityDouble * 100)
        } else {
            precipProbability = nil
        }
        summary = weatherDictionary["summary"] as? String
    }
}