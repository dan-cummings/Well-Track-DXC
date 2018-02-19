//
//  SettingsViewController.swift
//  Well Track
//
//  Created by Carolyn Quigley on 2/17/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var MinHeartField: UITextField!
    @IBOutlet weak var MaxHeartField: UITextField!
    @IBOutlet weak var MinTempField: UITextField!
    @IBOutlet weak var MaxTempField: UITextField!
    @IBOutlet weak var HoursField: UITextField!
    @IBOutlet weak var MinutesField: UITextField!
    @IBOutlet weak var ClearButton: UIButton!
    
    fileprivate var ref: DatabaseReference?
    //var userId

    override func viewDidLoad() {
        super.viewDidLoad()

        /*Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.userId = user.uid
                self.ref = Database.database().reference()
                self.registerForFirebaseUpdates()
                
            }
            
        }*/
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    @IBAction func saveSettings(_ sender: UIButton) {
        
        // update settings
        print("Saving...")
        print("Alert user if heart rate is outside of range: \(MinHeartField.text ?? "?") to \(MaxHeartField.text ?? "?")")
        print("Alert user if temperature is outside of range: \(MinTempField.text ?? "?") to \(MaxTempField.text ?? "?")")
        print("Alert user they have spent more than: \(HoursField.text ?? "0") hours and \(MinutesField.text ?? "0") at a location")
        if HoursField.text == "" {
            print("Hours not specified")
        }
        
        //let newSettings = self.ref?.child(self.userID)
    }
    
    func getSettingsDictionary () -> NSDictionary {
        return [
            "minHeart" : MinHeartField.text! as NSString,
            "maxHeart" : MaxHeartField.text! as NSString,
            "minTemp" : MinTempField.text! as NSString,
            "maxTemp" : MaxTempField.text! as NSString,
            "hours" : HoursField.text! as NSString,
            "minutes" : MinutesField.text! as NSString
        ]
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
