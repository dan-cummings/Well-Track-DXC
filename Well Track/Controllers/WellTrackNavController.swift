//
//  WellTrackNavController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/6/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

/// Navigation controller to act as the root of each tab item in the well track app.
class WellTrackNavController: UINavigationController {
    
    var uid: String?
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = uid else {
            print("No UID for user")
            return
        }
        ref = Database.database().reference(withPath: "users/\(uid!)")
        guard let _ = ref else {
            print("No reference made.")
            return
        }
    }
}
