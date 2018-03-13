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
    
    var userId: String?
    fileprivate var databaseRef: DatabaseReference?
    var mostRecent: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.startFireBase()
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startFireBase() {
        if let uid = userId {
            databaseRef = Database.database().reference(withPath: "\(uid)")
        } else {
            userId = Auth.auth().currentUser?.uid
            databaseRef = Database.database().reference(withPath: "\(userId!)")
        }
        mostRecent = Settings()
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
            // figure out how date works?
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
    
    @IBAction func saveSettings(_ sender: UIButton) {
        // get values from text fields and unwind to table view controller?
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        
        let vals = self.getSettingsDictionary()
        let settingsRef = self.saveLogToFirebase(key: mostRecent?.key, ref: database, vals: vals)
        
        //self.performSegue(withIdentifier: "setDefaultSettings", sender: self)
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
    
    @IBAction func alertChange(_ sender: UISwitch) {
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
    
    @IBAction func gpsChanged(_ sender: UISwitch) {
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
