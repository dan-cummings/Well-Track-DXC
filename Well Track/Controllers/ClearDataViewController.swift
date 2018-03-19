//
//  ClearDataViewController.swift
//  Well Track
//
//  Created by Carolyn Quigley on 3/2/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ClearDataViewController: UIViewController {

    @IBOutlet weak var fromDate: UIDatePicker!
    @IBOutlet weak var toDate: UIDatePicker!
    
    var userId: String?
    fileprivate var databaseRef: DatabaseReference!
    fileprivate var storageRef: Storage!
    var mostRecent: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userId = Auth.auth().currentUser?.uid
        self.startFireBase()
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
            storageRef = Storage.storage()
        }
        mostRecent = Settings()
    }
    
    // Remove logs from within the specified date range
    @IBAction func clearSomeData(_ sender: UIButton) {
        let startDate = fromDate.date
        let endDate = toDate.date
        // Loops through logs once
        self.databaseRef!.child("Logs").observeSingleEvent(of: .value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItem = HealthLog()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    tmpItem.key = val.0
                    let date = entry["date"] as! String
                    tmpItem.hasPicture = entry["hasPicture"] as! Int
                    tmpItem.hasVideo = entry["hasVideo"] as! Int
                    tmpItem.date = date.iso8601
                    if let date = tmpItem.date {
                        if (date <= endDate) && (date >= startDate) {
                            self.removeFromFirebase(key: tmpItem.key, ref: self.databaseRef, vals: tmpItem)
                        }
                    }
                }
            }
        })
        
    }
    
    func removeFromFirebase(key: String?, ref: DatabaseReference, vals: HealthLog) {
        if vals.hasVideo == 1 {
            ref.child("Logs/\(key!)/Videos").observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? [String : AnyObject] {
                    for (_,val) in values.enumerated() {
                        let entry = val.1 as! Dictionary<String,AnyObject>
                        let videoURL = entry["videoURL"] as! String
                        let imageURL = entry["imageURL"] as! String
                        Storage.storage().reference(forURL: videoURL).delete(completion: { (error) in
                            if let _ = error {
                                print("Error occurred deleting video")
                                return
                            }
                            print("Video Deleted")
                        })
                        self.storageRef.reference(forURL: imageURL).delete(completion: { (error) in
                            if let _ = error {
                                print("Error occurred deleting thumbnail")
                                return
                            }
                            print("Thumbnail Deleted")
                        })
                    }
                }})
        }
        if vals.hasPicture == 1 {
            ref.child("Logs/\(key!)/Pictures").observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? [String : AnyObject] {
                    for (_,val) in values.enumerated() {
                        let entry = val.1 as! Dictionary<String,AnyObject>
                        let imageURL = entry["imageURL"] as! String
                        self.storageRef.reference(forURL: imageURL).delete(completion: { (error) in
                            if let e = error {
                                print(e.localizedDescription)
                                return
                            }
                            print("Picture Deleted")
                        })
                    }
                }})
        }
        ref.child(key!).removeValue()
    }
    
    // Clears all logs from Firebase
    @IBAction func clearAllData(_ sender: UIButton) {
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
