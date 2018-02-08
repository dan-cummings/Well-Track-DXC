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

class WellTrackUITabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                for child in self.childViewControllers {
                    if let c = child as? WellTrackNavController {
                        c.uid = user.uid
                    }
                }
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func unwindFromRegistration(segue: UIStoryboardSegue) {
        
    }
}
