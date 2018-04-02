//
//  GoogleDataProvider.swift
//  Feed Me
//
/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import GooglePlaces

typealias PlacesCompletion = ([GooglePlace]) -> Void

class GoogleDataProvider {
    private var placesTask: URLSessionDataTask?
    private var dispatchgroup = DispatchGroup()
    private var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types: [String], completion: @escaping PlacesCompletion) -> Void {
        var placesArray: [GooglePlace] = []
        for type in types {
            dispatchgroup.enter()
            var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key=\(googleApiKey)"
            urlString += "&types=\(type)"
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? urlString
        
            guard let url = URL(string: urlString) else {
                completion([])
                return
            }
        
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        
            session.dataTask(with: url) { data, response, error in
                
                if let e = error {
                    print(e.localizedDescription)
                }
                
                defer {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                guard let data = data,
                    let json = try? JSON(data: data, options: .mutableContainers),
                    let results = json["results"].arrayObject as? [[String: Any]] else {
                        return
                }
                results.forEach {
                    let place = GooglePlace(dictionary: $0, acceptedTypes: types)
                    placesArray.append(place)
                }
                self.dispatchgroup.leave()
            }.resume()
        }
        dispatchgroup.wait()
        DispatchQueue.main.async {
            completion(placesArray)
        }
    }
}
