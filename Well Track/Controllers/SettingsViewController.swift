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
    @IBOutlet weak var AlertSwitch: UISwitch!
    @IBOutlet weak var GPSSwitch: UISwitch!
    
    var userId: String?
    fileprivate var databaseRef: DatabaseReference?
    var mostRecent: Settings?
    //var userId

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.startFireBase()
         /*
                self.ref = Database.database().reference()
                self.registerForFirebaseUpdates()*/
                
            }
        }
            
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    @IBAction func saveSettings(_ sender: UIButton) {
        
        // update settings
        /*print("Saving...")
        print("Alert user if heart rate is outside of range: \(MinHeartField.text ?? "?") to \(MaxHeartField.text ?? "?")")
        print("Alert user if temperature is outside of range: \(MinTempField.text ?? "?") to \(MaxTempField.text ?? "?")")
        print("Alert user they have spent more than: \(HoursField.text ?? "0") hours and \(MinutesField.text ?? "0") at a location")
        if HoursField.text == "" {
            print("Hours not specified")
        }*/
        
        //send to Firebase
        self.saveAll()
        print("Going to save all from save button.")
    }
    
    func saveAll() {
        print("Entered save all")
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        
        let vals = self.getSettingsDictionary()
        let settingsRef = self.saveLogToFirebase(key: mostRecent?.key, ref: database, vals: vals)
    }
    
    func saveLogToFirebase(key: String?, ref: DatabaseReference?, vals: NSMutableDictionary) -> DatabaseReference? {
        var child: DatabaseReference?
        if let k = key {
            child = ref?.child("Settings").child(k)
            child?.setValue(vals)
        } else {
            child = ref?.child("Settings").childByAutoId()
            child?.setValue(vals)
        }
        return child
    }
    
    func startFireBase() {
        if let uid = userId {
            databaseRef = Database.database().reference(withPath: "\(uid)/Settings")
        } else {
            userId = Auth.auth().currentUser?.uid
            databaseRef = Database.database().reference(withPath: "\(userId!)/Settings")
        }
        mostRecent = Settings()
        registerForFireBaseUpdates()
    }
    
    func getSettingsDictionary () -> NSMutableDictionary {
        print("Entered get settings dictionary")
        /*var heartMin: String?
        var heartMax: String?
        var tempMin: String?
        var tempMax: String?
        var hour: String?
        var min: String?
        if MinHeartField.text == "" {
            heartMin = mostRecent?.minHeart
        }
        else {
            heartMin = MinHeartField.text
        }*/
        var gpsInt: Int
        var alertInt: Int
        if GPSSwitch.isOn {
            gpsInt = 1
            print("GPS on")
        }
        else {
            gpsInt = 0
            print("GPS off")
        }
        if AlertSwitch.isOn {
            alertInt = 1
            print("alerts on")
        }
        else {
            alertInt = 0
            print("alerts off")
        }
        return [
            // figure out how date works
            //let currentDate = Date()
            //"date" : NSString(Date()),
            "minHeart" : MinHeartField.text! as NSString,
            "maxHeart" : MaxHeartField.text! as NSString,
            "minTemp" : MinTempField.text! as NSString,
            "maxTemp" : MaxTempField.text! as NSString,
            "hours" : HoursField.text! as NSString,
            "minutes" : MinutesField.text! as NSString,
            "gps" : gpsInt as NSInteger,
            "alert" : alertInt as NSInteger
        ]
    }
    // Unsure if needed
    func toDictionary (log: Settings) -> NSMutableDictionary {
        return [
            "date": NSString(string: (log.date?.iso8601)!),
            "minHeart" : log.minHeart! as NSString,
            "maxHeart" : log.maxHeart! as NSString,
            "minTemp" : log.minTemp! as NSString,
            "maxTemp" : log.maxTemp! as NSString,
            "hours" : log.hours! as NSString,
            "minutes" : log.minutes! as NSString
        ]
    }
    func registerForFireBaseUpdates() {
        print("Registering for updates")
        self.databaseRef!.child("Settings").observe(.value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItem = Settings()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    tmpItem.key = val.0
                    // to do
                    //let date = entry["date"] as! String
                    //tmpItem.date = date.iso8601
                    tmpItem.minHeart = entry["minHeart"] as? String
                    tmpItem.maxHeart = entry["maxHeart"] as? String
                    tmpItem.minTemp = entry["minTemp"] as? String
                    tmpItem.maxTemp = entry["maxTemp"] as? String
                    tmpItem.hours = entry["hours"] as? String
                    tmpItem.minutes = entry["minutes"] as? String
                    tmpItem.gps = entry["gps"] as! Int
                    tmpItem.alert = entry["alert"] as! Int
                    if self.mostRecent!.date != nil {
                        if (self.mostRecent?.date)! < tmpItem.date! {
                            self.mostRecent = tmpItem
                        }
                    } else {
                        self.mostRecent = tmpItem
                    }
                }
                if let _ = self.mostRecent {
                    print("Going to update, gps is \(tmpItem.gps) and alert is \(tmpItem.alert).")
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
            print("Most recent alert was on, so turning switch on.")
        }
        else {
            AlertSwitch.setOn(false, animated: true)
            print("Most recent alert was off, so turning switch off.")
        }
        self.changeAlertStatus()
        if mostRecent?.gps == 1 {
            GPSSwitch.setOn(true, animated: true)
            print("Most recent gps was on, so turning switch on.")
        }
        else {
            GPSSwitch.setOn(false, animated: true)
            print("Most recent gps was off, so turning switch off.")
        }
    }
    
    
    @IBAction func alertChange(_ sender: UISwitch) {
        self.saveAll()
        changeAlertStatus()
    }
    
    @IBAction func gpsChanged(_ sender: UISwitch) {
        self.saveAll()
    }
    
    
    @IBAction func clearAllData(_ sender: UIButton) {
        // TO DO
        // probably want to figure out how to present the user with an "are you sure?" window
    }
    
    func changeAlertStatus() {
        let enabled = AlertSwitch.isOn
        MinTempField.isEnabled = enabled
        MaxTempField.isEnabled = enabled
        MinHeartField.isEnabled = enabled
        MaxHeartField.isEnabled = enabled
        HoursField.isEnabled = enabled
        MinutesField.isEnabled = enabled
        
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
