//
//  DefaultSettingsViewController.swift
//  Well Track
//
//  Created by Carolyn Quigley on 3/4/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import Firebase

class DefaultSettingsViewController: UIViewController {

    @IBOutlet weak var MinHeartField: UITextField!
    @IBOutlet weak var MaxHeartField: UITextField!
    @IBOutlet weak var MinTempField: UITextField!
    @IBOutlet weak var MaxTempField: UITextField!
    @IBOutlet weak var HoursField: UITextField!
    @IBOutlet weak var MinutesField: UITextField!
    @IBOutlet weak var AlertSwitch: UISwitch!
    @IBOutlet weak var GPSSwitch: UISwitch!
    @IBOutlet weak var linkButton: UIButton!
    
    var userId: String?
    var settingsRecord: Settings!
    var authentication: ThermoDataProvider!
    fileprivate var databaseRef: DatabaseReference?
    var authenticated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authentication = ThermoDataProvider()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.startFirebase()
            }
        }
        settingsRecord
            = Settings(minTemp: "97.9", maxTemp: "99.0", minHeart: "60",
                       maxHeart: "100", hours: "0", minutes: "30", gps: 1, alert: 1, nokiaAccount: 0, authToken: "", authSec: "", userID: "")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startFirebase() {
        if let uid = userId {
            databaseRef = Database.database().reference(withPath: "\(uid)")
        } else {
            userId = Auth.auth().currentUser?.uid
            databaseRef = Database.database().reference(withPath: "\(userId!)")
        }
    }
    
    func getSettingsDictionary () -> NSMutableDictionary {
        let gpsInt = GPSSwitch.isOn ? 1 : 0
        let alertInt = AlertSwitch.isOn ? 1 : 0
        return [
            "minHeart" : settingsRecord.minHeart! as NSString,
            "maxHeart" : settingsRecord.maxHeart! as NSString,
            "minTemp" : settingsRecord.minTemp! as NSString,
            "maxTemp" : settingsRecord.maxTemp! as NSString,
            "hours" : settingsRecord.hours! as NSString,
            "minutes" : settingsRecord.minutes! as NSString,
            "gps" : gpsInt as NSInteger,
            "alert" : alertInt as NSInteger,
            "nokiaAccount": settingsRecord.nokiaAccount as NSInteger,
            "authToken": settingsRecord.authToken! as NSString,
            "authSec": settingsRecord.authSec! as NSString,
            "userID": settingsRecord.userID! as NSString
        ]
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        // get values from text fields and unwind to table view controller?
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        
        let vals = self.getSettingsDictionary()
        database.child("Settings").childByAutoId().setValue(vals)
    }
    
    @IBAction func alertChange(_ sender: UISwitch) {
        let enabled = AlertSwitch.isOn
        MinTempField.isEnabled = enabled
        MaxTempField.isEnabled = enabled
        MinHeartField.isEnabled = enabled
        MaxHeartField.isEnabled = enabled
        
        let color = enabled ? UIColor.black : UIColor.gray
        
        MinTempField.textColor = color
        MaxTempField.textColor = color
        MinHeartField.textColor = color
        MaxHeartField.textColor = color
    }
    
    @IBAction func gpsChanged(_ sender: UISwitch) {
        let enabled = GPSSwitch.isOn
        HoursField.isEnabled = enabled
        MinutesField.isEnabled = enabled
        
        let color = enabled ? UIColor.black : UIColor.gray
        
        HoursField.textColor = color
        MinutesField.textColor = color
    }
    
    @IBAction func authenticateNokiaAccount(_ sender: Any) {
        if self.authenticated {
            self.authenticated = false
            self.settingsRecord.nokiaAccount = 0
            self.settingsRecord.authSec = ""
            self.settingsRecord.userID = ""
            self.settingsRecord.authToken = ""
            self.linkButton.titleLabel?.text = "Link Nokia Health Account"
        } else {
            authentication.authenticate { (id, token, secret) in
                self.settingsRecord.nokiaAccount = 1
                self.settingsRecord.authSec = secret
                self.settingsRecord.userID = id
                self.settingsRecord.authToken = token
                self.authenticated = true
                DispatchQueue.main.async {
                    self.linkButton.titleLabel?.text = "Unlink Nokia Health Account"
                }
            }
        }
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        switch sender.tag {
        case 0:
            settingsRecord?.minHeart = sender.text
        case 1:
            settingsRecord?.maxHeart = sender.text
        case 2:
            settingsRecord?.minTemp = sender.text
        case 3:
            settingsRecord?.maxTemp = sender.text
        case 4:
            settingsRecord?.hours = sender.text
        case 5:
            settingsRecord?.minutes = sender.text
        default:
            break
        }
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
