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
import OAuthSwift

class ThermoDataProvider {
    var mostRecentTemp: Double?
    private var placesTask: URLSessionDataTask?
    private var dispatchgroup = DispatchGroup()
    private var oauthswift: OAuth1Swift?
    private var authToken: String?
    private let conKey = "f1e408931983fde42f0fe43b6ecd7138891e7edf302d772cb5b0ed23b"
    private var signature: String?
    private var session: URLSession {
        return URLSession.shared
    }
    
    
    func fetchTempInRange(_ hours: Int) -> Double {
        mostRecentTemp = -1.0
        // added
        //if authToken == nil {
        oauthswift = OAuth1Swift(
            consumerKey:    conKey,
            consumerSecret: "2970fbd3d1b29ef55146b4717987196973fc315576d5920499092cffdb1b6f8",
            requestTokenUrl: "https://developer.health.nokia.com/account/request_token",
            authorizeUrl:    "https://developer.health.nokia.com/account/authorize",
            accessTokenUrl:  "https://developer.health.nokia.com/account/access_token"
        )
        print("did the thing, about to authorize")
        print("Date: \(Date().timeIntervalSince1970)")
        // authorize
        let handle = oauthswift?.authorize(
            withCallbackURL: URL(string: "well-track://")!,
            success: { credential, response, parameters in
                print("Token: \(credential.oauthToken)")
                self.authToken = credential.oauthToken
                print(credential.oauthTokenSecret)
                //TO DO remove oops
                print(parameters["userid"] ?? "Oops")
                // Do your request
                self.makeRequest(userID: parameters["userid"] as! String)
            },
            failure: { error in
                print(error.localizedDescription)
                print("Oh nooooo")
        })
        
        
        /*
        var temp: Double
        let unEpoch = Date().timeIntervalSince1970
        let method = "HMAC-SHA1"
        let key = "f1e408931983fde42f0fe43b6ecd7138891e7edf302d772cb5b0ed23b"
        dispatchgroup.enter()
        // need to format dates correctly and add oauth stuff
        var urlString = "https://api.health.nokia.com/measure?action=getmeas&userid=\(userID)&startdate=\(startDate)&enddate=\(endDate)&meastype=12&oauth_signature_method=\(method)&oauth_timestamp=\(unEpoch)&oauth_version=1.0"
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
            /*results.forEach {
                //let place = GooglePlace(dictionary: $0, acceptedTypes: types)
                //placesArray.append(place)
            }*/
            self.dispatchgroup.leave()
            }.resume()
        dispatchgroup.wait()
        DispatchQueue.main.async {
            //completion(placesArray)
        }*/
        //return mostRecentTemp!
        return 98.0
    }
    func makeRequest(userID: String) {
        print("Making request for user \(userID)")
        let url :String = "https://api.health.nokia.com/measure?action=getmeas&userid=\(userID)&lastupdate=\(Date().timeIntervalSince1970 - 2592000)&meastype=12&oauth_consumer_key=\(conKey)&oauth_nonce=AVBH6152&oauth_signature=\(signature ?? "no")&oauth_signature_method=HMAC-SHA1&oauth_timestamp=\(Date().timeIntervalSince1970)&oauth_token=\(authToken ?? "no")&oauth_version=1.0"
        /*let parameters :Dictionary = [
            "userid"                : userID,
            "lastupdate"            : Date().timeIntervalSince1970 - 2592000,
            "meastype"              : "4"//,
            //"limit"                 : 1//,
            //"oauth_consumer_key"    : "f1e408931983fde42f0fe43b6ecd7138891e7edf302d772cb5b0ed23b",
            
            ] as [String : Any]*/
        //print("Paramaters!:")
        //print(parameters)
        let _ = oauthswift?.client.get(
            url, //parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
                print("jsonDict: \(jsonDict as Any)")
        },
            failure: { error in
                print(error)
        }
        )
    }
}

