//
//  Extensions.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseStorage

extension Date {
    struct Formatter {
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            return formatter
        } ()
        static let iso8601: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter.init()
            formatter.timeZone = TimeZone.current
            return formatter
        } ()
        static let time: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        } ()
    }
    
    var short: String {
        return Formatter.short.string(from: self)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    var time: String {
        return Formatter.time.string(from: self)
    }
}

extension String {
    var dateFromShort: Date? {
        return Date.Formatter.short.date(from: self)
    }
    
    var iso8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageFromCacheUsingURL(urlString: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let storageRef = Storage.storage().reference(forURL: urlString)
        storageRef.getData(maxSize: 16 * 1024 * 1024, completion: { (data, error) in
            if let e = error {
                print("\(e.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        })
    }
}
