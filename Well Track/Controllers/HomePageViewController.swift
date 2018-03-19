//
//  HomePageViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

/// The home page to display the most recent log that was added and act as the hub for the user settings.
class HomePageViewController: UIViewController {

    @IBOutlet weak var noLogsLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var heartrateLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var healthRatingImage: UIImageView!
    
    var userId: String?
    var mostRecent: HealthLog?
    fileprivate var databaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.isHidden = true
        temperatureLabel.isHidden = true
        heartrateLabel.isHidden = true
        moodLabel.isHidden = true
        healthRatingImage.isHidden = true
        noLogsLabel.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()
        
        healthRatingImage.tintColor = .black
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.startFirebase()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = databaseRef {
            self.registerForFireBaseUpdates()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = databaseRef {
            databaseRef?.removeAllObservers()
        }
    }
    
    /// Function to set up the view controller to receive updates from firebase.
    fileprivate func registerForFireBaseUpdates() {
        self.databaseRef!.observeSingleEvent(of: .value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItem = HealthLog()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    tmpItem.key = val.0
                    //TODO Temp fix needs refactoring.
                    if !snapshot.hasChild("\(tmpItem.key!)/temperature") {
                        continue
                    }
                    tmpItem.temperature = entry["temperature"] as! String
                    let date = entry["date"] as! String
                    tmpItem.date = date.iso8601
                    tmpItem.heartrate = entry["heartrate"] as! String
                    tmpItem.moodrating = entry["moodRating"] as! String
                    tmpItem.hasText = entry["hasText"] as! Int
                    tmpItem.text = entry["text"] as? String
                    tmpItem.hasPicture = entry["hasPicture"] as! Int
                    tmpItem.hasVideo = entry["hasVideo"] as! Int
                    tmpItem.hasLocation = entry["hasLocation"] as! Int
                    tmpItem.latitude = entry["latitude"] as? Float
                    tmpItem.longitude = entry["longitude"] as? Float
                    if self.mostRecent!.date != nil {
                        if (self.mostRecent?.date)! < tmpItem.date! {
                            self.mostRecent = tmpItem
                        }
                    } else {
                        self.mostRecent = tmpItem
                    }
                }
                if let _ = self.mostRecent {
                    self.updateFields()
                } else {
                    self.noLogsLabel.isHidden = false
                }
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            }})
    }

    
    /// Updates the view to display the log information.
    func updateFields() {
        switch mostRecent!.moodrating {
        case "Fine":
            healthRatingImage.image = UIImage(named: "Fair")
            break
        case "Good":
            healthRatingImage.image = UIImage(named: "Good")
            break
        case "Great":
            healthRatingImage.image = UIImage(named: "Great")
            break
        case "Bad":
            healthRatingImage.image = UIImage(named: "Bad")
            break
        case "Terrible":
            healthRatingImage.image = UIImage(named: "Terrible")
            break
        default:
            break
        }
        
        dateLabel.text = mostRecent!.date?.short
        temperatureLabel.text = mostRecent?.temperature
        heartrateLabel.text = mostRecent?.heartrate
        moodLabel.text = mostRecent?.moodrating
        
        dateLabel.isHidden = false
        temperatureLabel.isHidden = false
        heartrateLabel.isHidden = false
        moodLabel.isHidden = false
        healthRatingImage.isHidden = false
    }
    
    /// Helper function to prepare the reference to the firebase database.
    func startFirebase() {
        if let uid = userId {
            databaseRef = Database.database().reference(withPath: "\(uid)/Logs")
        } else {
            userId = Auth.auth().currentUser?.uid
            databaseRef = Database.database().reference(withPath: "\(userId!)/Logs")
        }
        mostRecent = HealthLog()
        registerForFireBaseUpdates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Handles when the user logs out of the app.
    ///
    /// - Parameter sender: The button connected to this action.
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
