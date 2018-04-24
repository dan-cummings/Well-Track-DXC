//
//  WellTrackUITabController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/4/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

/// The root controller for the TabViewController.
class WellTrackUITabController: UITabBarController {
    
    private var placeSweeper: PlacesSearch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = TEXT_DEFAULT_COLOR
        self.tabBar.barTintColor = TEXT_DEFAULT_COLOR
        self.tabBar.tintColor = TEXT_HIGHLIGHT_COLOR
        placeSweeper = PlacesSearch.shared
        placeSweeper.setupLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                for child in self.childViewControllers {
                    if let c = child as? WellTrackNavController {
                        c.uid = user.uid
                    }
                }
                self.checkFirebase(uid: user.uid)
            } else {
                self.placeSweeper.turnOffLocationService()
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    fileprivate func checkFirebase(uid: String) {
        Database.database().reference(withPath: "\(uid)/Settings").observeSingleEvent(of: .value) { (snapshot) in
            if let values = snapshot.value as? [String : AnyObject] {
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    let gps = entry["gps"] as! Int
                    if gps == 1 {
                        self.placeSweeper.startLocationServices(uid: uid)
                    }
                }
            }
        }
    }
    
    @IBAction func unwindFromRegistration(segue: UIStoryboardSegue) {
        
    }
}
