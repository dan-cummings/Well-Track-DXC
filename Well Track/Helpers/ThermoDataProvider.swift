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
        print("did the thing, about to authorize")
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
                self.makeRequest(userID: parameters["userid"] as! String)
            },
            failure: { error in
                print(error.localizedDescription)
                print("Oh nooooo")
        })
        
        //return mostRecentTemp!
        return 98.0
    }
    func makeRequest(userID: String) {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        print("Making request for user \(userID)")
        let time = Int(Date().timeIntervalSince1970)
        let domain :String = "https://api.health.nokia.com/measure?action=getmeas"
        let path = "userid=\(userID)&meastype=12&oauth_consumer_key=\(conKey)&oauth_nonce=AVBH6152&oauth_signature_method=HMAC-SHA1&oauth_timestamp=\(time)&oauth_token=\(authToken ?? "no")&oauth_version=1.0"
        let normDomain = domain.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        let normPath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet);
        let key = "\(conSec)&\(tokenSec!)"
        let normalized = "GET&\(normDomain!)&\(normPath!)"
        signature = normalized.digestHMac1(key: key)
        let url :String = "https://api.health.nokia.com/measure?action=getmeas&userid=\(userID)&meastype=12&oauth_consumer_key=\(conKey)&oauth_nonce=AVBH6152&oauth_signature=\(signature ?? "no")&oauth_signature_method=HMAC-SHA1&oauth_timestamp=\(time)&oauth_token=\(authToken ?? "no")&oauth_version=1.0"
        print(url)
        let _ = oauthswift?.client.get(
            url,
            success: { response in
                let jsonDict = try? response.jsonObject()
                print("jsonDict: \(jsonDict as Any)")
        },
            failure: { error in
                print(error.localizedDescription)
        }
        )
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
        
        let hash = data.base64EncodedString()
        
        return hash
    }
}
