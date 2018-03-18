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
    @IBOutlet weak var AlertSwitch: UISwitch!
    @IBOutlet weak var GPSSwitch: UISwitch!
    
    var userId: String?
    fileprivate var databaseRef: DatabaseReference?
    var mostRecent: Settings!

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.startFireBase()
                
            }
        }
        mostRecent = Settings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    @IBAction func saveSettings(_ sender: UIButton) {
        
        //send to Firebase
        self.saveAll()
        print("Going to save all from save button.")
    }
    
    func saveAll() {
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        
        let vals = self.getSettingsDictionary()
        self.saveLogToFirebase(key: mostRecent?.key, ref: database, vals: vals)
    }
    
    func saveLogToFirebase(key: String?, ref: DatabaseReference?, vals: NSMutableDictionary) {
        if let k = key {
            ref?.child("Settings").child(k).setValue(vals)
        } else {
            ref?.child("Settings").childByAutoId().setValue(vals)
        }
    }
    
    func startFireBase() {
        if let uid = userId {
            databaseRef = Database.database().reference(withPath: "\(uid)")
        } else {
            userId = Auth.auth().currentUser?.uid
            databaseRef = Database.database().reference(withPath: "\(userId!)")
        }
        mostRecent = Settings()
        registerForFireBaseUpdates()
    }
    
    func getSettingsDictionary () -> NSMutableDictionary {
        var gpsInt: Int
        var alertInt: Int
        if GPSSwitch.isOn {
            gpsInt = 1
        }
        else {
            gpsInt = 0
        }
        if AlertSwitch.isOn {
            alertInt = 1
        }
        else {
            alertInt = 0
        }
        return [
            "minHeart" : mostRecent.minHeart! as NSString,
            "maxHeart" : mostRecent.maxHeart! as NSString,
            "minTemp" : mostRecent.minTemp! as NSString,
            "maxTemp" : mostRecent.maxTemp! as NSString,
            "hours" : mostRecent.hours! as NSString,
            "minutes" : mostRecent.minutes! as NSString,
            "gps" : gpsInt as NSInteger,
            "alert" : alertInt as NSInteger
        ]
    }
    
    func registerForFireBaseUpdates() {
        self.databaseRef!.child("Settings").observe(.value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItem = Settings()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    tmpItem.key = val.0
                    tmpItem.minHeart = entry["minHeart"] as? String
                    tmpItem.maxHeart = entry["maxHeart"] as? String
                    tmpItem.minTemp = entry["minTemp"] as? String
                    tmpItem.maxTemp = entry["maxTemp"] as? String
                    tmpItem.hours = entry["hours"] as? String
                    tmpItem.minutes = entry["minutes"] as? String
                    tmpItem.gps = entry["gps"] as! Int
                    tmpItem.alert = entry["alert"] as! Int
                }
                self.mostRecent = tmpItem
                if let _ = self.mostRecent {
                    self.updateFields()
                }
            }})
    }

    func updateFields() {
        MinHeartField.text = mostRecent?.minHeart
        MaxHeartField.text = mostRecent?.maxHeart
        MinTempField.text = mostRecent?.minTemp
        MaxTempField.text = mostRecent?.maxTemp
        HoursField.text = mostRecent?.hours
        MinutesField.text = mostRecent?.minutes
        
        if mostRecent?.alert == 1 {
            AlertSwitch.setOn(true, animated: true)
        }
        else {
            AlertSwitch.setOn(false, animated: true)
        }
        self.changeAlertStatus()
        if mostRecent?.gps == 1 {
            GPSSwitch.setOn(true, animated: true)
        }
        else {
            GPSSwitch.setOn(false, animated: true)
        }
        self.changeGPSStatus()
    }
    
    
    @IBAction func alertChange(_ sender: UISwitch) {
        self.saveAll()
        changeAlertStatus()
    }
    
    @IBAction func gpsChanged(_ sender: UISwitch) {
        self.saveAll()
        changeGPSStatus()
    }
    
    
    func changeAlertStatus() {
        let enabled = AlertSwitch.isOn
        MinTempField.isEnabled = enabled
        MaxTempField.isEnabled = enabled
        MinHeartField.isEnabled = enabled
        MaxHeartField.isEnabled = enabled
        
        var color: UIColor
        if AlertSwitch.isOn {
            color = UIColor.black
        }
        else {
            color = UIColor.gray
        }
        
        MinTempField.textColor = color
        MaxTempField.textColor = color
        MinHeartField.textColor = color
        MaxHeartField.textColor = color
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        switch sender.tag {
        case 0:
            mostRecent.minHeart = MinHeartField.text
        case 1:
            mostRecent.maxHeart = MaxHeartField.text
        case 2:
            mostRecent.minTemp = MinTempField.text
        case 3:
            mostRecent.maxTemp = MaxTempField.text
        case 4:
            mostRecent.hours = HoursField.text
        case 5:
            mostRecent.minutes = MinutesField.text
        default:
            break
        }
    }
    func changeGPSStatus() {
        let enabled = GPSSwitch.isOn
        HoursField.isEnabled = enabled
        MinutesField.isEnabled = enabled
        
        var color: UIColor
        if GPSSwitch.isOn {
            color = UIColor.black
        }
        else {
            color = UIColor.gray
        }
        
        HoursField.textColor = color
        MinutesField.textColor = color
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
