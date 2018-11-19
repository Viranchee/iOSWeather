//
//  WeatherController.swift
//  Commute
//
//  Created by Stephen Francis on 2/17/17.
//  Copyright © 2017 Stephen Francis. All rights reserved.
//
import CoreLocation

typealias JSONPayload = [String : Any]

// this is what we provide as a result to the caller who requests weather from the WeatherController
typealias WeatherTuple = (temperature: Float, description: String)

enum WeatherError: Error {
    case requestFailed
    case noData
    case serializationFailed
    case parsingFailed
}

// this is very simple and just has the temp as a Float, and description as a String,
// you might want to replace this with a more robust result
enum WeatherResult {
    case success(WeatherTuple)
    case failure(WeatherError)
}
class WeatherController {
    static let shared = WeatherController()
    
    let session = URLSession.shared
    // FIXME: you must replace this with your OpenWeather API key (APPID), see https://openweathermap.org/appid
    fileprivate let APIKey = "yourAPIKey"
    fileprivate let baseURLPath = "http://api.openweathermap.org/data/2.5/weather?"
    
    // singleton should not be initialized elsewhere
    fileprivate init() {}
    
    typealias WeatherCompletion = (WeatherResult) -> Void
    
    // format: http://api.openweathermap.org/data/2.5/weather?lat=42.365486&lon=71.103802&APPID=yourAPIKey
    func weatherURL(for coordinate: CLLocationCoordinate2D) -> URL {
        let URLPath = baseURLPath + "lat=\(coordinate.latitude)" + "&lon=\(coordinate.longitude)" + "&units=imperial" + "&APPID=\(APIKey)"
        return URL(string: URLPath)!
    }
    
    func weather(coordinate: CLLocationCoordinate2D, completion: @escaping WeatherCompletion) {
        session.dataTask(with: weatherURL(for: coordinate)) { data, URLResponse, requestError in
            guard let data = data else {
                if let _ = requestError {
                    completion(.failure(.requestFailed))
                } else {
                    print("WeatherController: data is nil, but there is no error!")
                }
                
                return
            }
            
            do {
                guard let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSONPayload else {
                    completion(.failure(.serializationFailed))
                    return
                }
                
                guard let weatherResult = self.parse(JSON) else {
                    completion(.failure(.parsingFailed))
                    return
                }
                
                completion(.success(weatherResult))
            } catch {
                completion(.failure(.serializationFailed))
            }
            }.resume()
    }
    
    func parse(_ payload: JSONPayload) -> WeatherTuple? {
        guard let temp = (payload["main"] as? JSONPayload)?["temp"] as? Float else { return nil }
        
        // man JSON parsing in Swift is ug, i should give SwiftyJSON a try
        guard let description = ((payload["weather"]) as? [JSONPayload])?.first?["description"] as? String else { return nil }
        
        return (temp, description)
    }
}
