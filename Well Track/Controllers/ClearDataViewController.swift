//
//  ClearDataViewController.swift
//  Well Track
//
//  Created by Carolyn Quigley on 3/2/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import Firebase

class ClearDataViewController: UIViewController {

    @IBOutlet weak var fromDate: UIDatePicker!
    @IBOutlet weak var toDate: UIDatePicker!
    
    var userId: String?
    fileprivate var databaseRef: DatabaseReference?
    var mostRecent: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.startFireBase()
                
            }
        }
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func clearSomeData(_ sender: UIButton) {
        let startDate = fromDate.date
        let endDate = toDate.date

        self.databaseRef!.child("Logs").observeSingleEvent(of: .value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItem = HealthLog()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    tmpItem.key = val.0
                    let date = entry["date"] as! String
                    tmpItem.date = date.iso8601
                    if tmpItem.date != nil {
                        if (tmpItem.date! <= endDate) && (tmpItem.date! >= startDate) {
                            print("Remove log with date \(String(describing: tmpItem.date)) and key \(String(describing: tmpItem.key))")
                            self.databaseRef?.child("Logs").child(tmpItem.key!).removeValue()
                        }
                    }
                }
            }
        })
        
    }
    
    @IBAction func clearAllData(_ sender: UIButton) {
        //let settingsDatabaseRef = Database.database().reference(withPath: "\(userId!)/Settings")
        let logDatabaseRef = Database.database().reference(withPath: "\(userId!)/Logs")
        logDatabaseRef.removeValue()
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
