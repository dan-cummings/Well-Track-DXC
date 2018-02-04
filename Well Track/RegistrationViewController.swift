//
//  RegistrationViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/3/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Eureka
import ImageRow

protocol RegistrationDelegate {
    func populateFields();
}

class RegistrationViewController: FormViewController {
    
    var handle: NSObjectProtocol?
    var delegate: RegistrationDelegate?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Photo")
            <<< ImageRow(){ row in
                row.title = "Select a photo"
                row.sourceTypes = .PhotoLibrary
                row.clearAction = .no
                }.cellUpdate{ cell, row in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
