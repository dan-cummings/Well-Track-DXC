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
    private var tokenSec: String?
    private let conKey = "f1e408931983fde42f0fe43b6ecd7138891e7edf302d772cb5b0ed23b"
    private let conSec = "2970fbd3d1b29ef55146b4717987196973fc315576d5920499092cffdb1b6f8"
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
            consumerSecret: conSec,
            requestTokenUrl: "https://developer.health.nokia.com/account/request_token",
            authorizeUrl:    "https://developer.health.nokia.com/account/authorize",
            accessTokenUrl:  "https://developer.health.nokia.com/account/access_token"
        )
        print("Date: \(Date().timeIntervalSince1970)")
        // authorize
        let _ = oauthswift?.authorize(
            withCallbackURL: URL(string: "well-track://")!,
            success: { credential, response, parameters in
                print("Token: \(credential.oauthToken)")
                self.authToken = credential.oauthToken
                print(credential.oauthTokenSecret)
                self.tokenSec = credential.oauthTokenSecret
                
                //TO DO remove oops
                print(parameters["userid"] ?? "Oops")
                // Do your request
                self.mostRecentTemp = self.makeRequest(userID: parameters["userid"] as! String)
            },
            failure: { error in
                print(error.localizedDescription)
                print("Oh nooooo")
        })
        
        //return mostRecentTemp!
        return mostRecentTemp!
    }
    func makeRequest(userID: String) -> Double {
        var uuid: CFUUID = CFUUIDCreate(nil)
        var nonce: CFString = CFUUIDCreateString(nil, uuid)
        
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        print("Making request for user \(userID)")
        let time = Int(Date().timeIntervalSince1970)
        let domain :String = "https://api.health.nokia.com/measure"
        let path = "action=getmeas&meastype=71&oauth_consumer_key=\(conKey)&oauth_nonce=\(nonce)&oauth_signature_method=HMAC-SHA1&oauth_timestamp=\(time)&oauth_token=\(authToken!)&oauth_version=1.0&userid=\(userID)"
        let normDomain = domain.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        let normPath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet);
        let key = "\(conSec)&\(tokenSec!)"
        let normalized = "GET&\(normDomain!)&\(normPath!)"
        signature = normalized.digestHMac1(key: key)
        let url :String = "https://api.health.nokia.com/measure?action=getmeas&meastype=71&oauth_consumer_key=\(conKey)&oauth_nonce=\(nonce)&oauth_signature=\(signature!)&oauth_signature_method=HMAC-SHA1&oauth_timestamp=\(time)&oauth_token=\(authToken!)&oauth_version=1.0&userid=\(userID)"
        print(url)
        let session = URLSession.shared
        let task = session.dataTask(with: URL(string: url)!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else if let data = data, let json = try? JSON(data: data, options: .mutableContainers) {
                //TODO get the data and parse it.
                let dataString = String(data: data, encoding: .utf8)
                print(dataString!)
                print("Trying to get bits")
                
                print(json)
                let body = json["body"]
                let results = body["measuregrps"][0]//.arrayObject as? [[String: Any]]
                
                print(results)
                
                print("Unit: \(results["measures"][0]["unit"])")
                // TODO: get the unit as an int
                let unit = results["measures"][0]["unit"] as? Int
                
                //print("Value: \(measures["value"] ?? "NA")")
                //print(result["measures"])
                /*
                let measures :[String: Any] = result["measures"] as! [String : Any]
                print("Unit: \(measures["unit"] ?? "NA")")
                print("Value: \(measures["value"] ?? "NA")")
                
                results?.forEach {item in
                    print("Item: \(item)")
                    print("Date: \(item["date"] ?? "NA")")
                }*/
            }
        }
        task.resume()
        
        return 99.0
    }
}

// from Trux's blog
extension String {
    
    func digestHMac1(key: String) -> String! {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = self.lengthOfBytes(using: String.Encoding.utf8)
        
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<Any>.allocate(capacity: digestLen)
        
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = key.lengthOfBytes(using: String.Encoding.utf8)
        
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA1)
        
        CCHmac(algorithm, keyStr!, keyLen, str!, strLen, result)
        
        let data = NSData(bytesNoCopy: result, length: digestLen)
        
        let hash = data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return hash
    }
}

