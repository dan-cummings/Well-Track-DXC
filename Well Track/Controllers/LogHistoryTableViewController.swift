//
//  LogHistoryTableViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import MGSwipeTableCell

class LogHistoryTableViewController: UITableViewController {
    
    var uid: String!
    fileprivate var databaseRef: DatabaseReference?
    fileprivate var storageRef: StorageReference?
    
    var tableViewData: [(sectionHeader: String, logs: [HealthLog])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let parent = self.parent as? WellTrackNavController {
            if parent.uid != nil {
                uid = parent.uid
            } else {
                uid = Auth.auth().currentUser?.uid
            }
        }
        guard let id = uid else {
            return
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        databaseRef = Database.database().reference(withPath: "\(id)/Logs")
        self.registerForFireBaseUpdates()
        storageRef = Storage.storage().reference()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let count = self.tableViewData?.count {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            return count
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = "No data found"
            label.textColor = .black
            label.textAlignment = .center
            tableView.backgroundView = label
            tableView.separatorStyle = .none
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData?[section].logs.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WellTrackTableViewCell
        
        guard let log = self.tableViewData?[indexPath.section].logs[indexPath.row] else {
            return cell
        }
        
        cell.log = log
        cell.temperatureLabel.text = log.temperature
        cell.heartRateLabel.text = log.heartrate
        cell.moodLabel.text = log.moodrating
        
        switch log.moodrating {
        case "Fine":
            cell.moodImage.image = UIImage(named: "Fair")
            break
        case "Good":
            cell.moodImage.image = UIImage(named: "Good")
            break
        case "Great":
            cell.moodImage.image = UIImage(named: "Great")
            break
        case "Bad":
            cell.moodImage.image = UIImage(named: "Bad")
            break
        case "Terrible":
            cell.moodImage.image = UIImage(named: "Terrible")
            break
        default:
            break
        }
        
        cell.moodImage.tintColor = .black

        
        //MG cell setup
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red)]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoView = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LogInformation") as! LogInformationViewController
        guard let log = self.tableViewData?[indexPath.section].logs[indexPath.row] else {
            return
        }
        infoView.log = log
        infoView.delegate = self
        self.navigationController?.pushViewController(infoView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableViewData?[section].sectionHeader
    }

    /// Helper function to sort the logs from firebase into sections based on their shortened dates.
    ///
    /// - Parameter logs: Collection of log objects to be sorted.
    func sortLogsIntoSections(_ logs: [HealthLog]) {
        var tempSorted = [String: [HealthLog]]()
        for log in logs {
            if let _ = tempSorted.index(forKey:(log.date?.short)!) {
                tempSorted[(log.date?.short)!]?.append(log);
            } else {
                tempSorted[(log.date?.short)!] = [HealthLog]()
                var sectLog = [HealthLog]()
                sectLog.append(log)
                tempSorted[(log.date?.short)!] = sectLog
            }
        }
        var temp = [(sectionHeader: String, logs: [HealthLog])]()
        for (date, sectLogs) in tempSorted {
            temp.append((sectionHeader: date, logs: sectLogs))
        }
        tableViewData = temp
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newLogSegue" {
            if let dest = segue.destination as? LogCreationViewController {
                dest.delegate = self
            }
        }
    }
    
    fileprivate func registerForFireBaseUpdates() {
        self.databaseRef!.observe(.value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItems = [HealthLog]()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    let key = val.0
                    let temperature = entry["temperature"] as! String
                    let date = entry["date"] as! String
                    let heartrate = entry["heartrate"] as! String
                    let moodrating = entry["moodRating"] as! String
                    let hasText = entry["hasText"] as! Int
                    let text = entry["text"] as! String
                    let hasPicture = entry["hasPicture"] as! Int
                    let hasVideo = entry["hasVideo"] as! Int
                    tmpItems.append(HealthLog(key: key, date: date.iso8601,
                                              temperature: temperature, heartrate: heartrate,
                                              moodrating: moodrating, hasText: hasText, text: text,
                                              hasPicture: hasPicture, hasVideo: hasVideo))
                }
                self.sortLogsIntoSections(tmpItems)
            }})
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".jpg")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func toDictionary(log: HealthLog) -> NSMutableDictionary {
        return [
            "date": NSString(string: (log.date?.iso8601)!),
            "temperature": log.temperature as NSString,
            "heartrate": log.heartrate as NSString,
            "moodRating": log.moodrating as NSString,
            "hasText": log.hasText as NSNumber,
            "text": log.text! as NSString,
            "hasPicture": log.hasPicture as NSNumber,
            "hasVideo": log.hasVideo as NSNumber,
        ]
    }
    
    func removeFromFirebase(key: String?, ref: DatabaseReference, vals: HealthLog) {
        if vals.hasVideo == 1 {
            ref.child("\(key!)/Videos").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let values = snapshot.value as? [String : AnyObject] {
                        for (_,val) in values.enumerated() {
                            let entry = val.1 as! Dictionary<String,AnyObject>
                            let videoURL = entry["videoURL"] as! String
                            let imageURL = entry["imageURL"] as! String
                            self.storageRef?.child(videoURL).delete(completion: { (error) in
                                if let _ = error {
                                    print("Error occurred deleting video")
                                    return
                                }
                                print("Video Deleted")
                                })
                            self.storageRef?.child(imageURL).delete(completion: { (error) in
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
            ref.child("\(key!)/Pictures").observeSingleEvent(of: .value, with: { (snapshot) in
                if let values = snapshot.value as? [String : AnyObject] {
                    for (_,val) in values.enumerated() {
                        let entry = val.1 as! Dictionary<String,AnyObject>
                        let imageURL = entry["imageURL"] as! String
                        Storage.storage().reference(forURL: imageURL).delete(completion: { (error) in
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
    
    func saveLogToFirebase(key: String?, ref: DatabaseReference?, vals: NSMutableDictionary) {
        var child: DatabaseReference?
        if let k = key {
            child = ref?.child(k)
            child?.updateChildValues(vals as! [AnyHashable : Any])
        } else {
            child = ref?.childByAutoId()
            child?.setValue(vals)
        }
    }
}

extension LogHistoryTableViewController: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        // Right now the only button is delete so we can simply call the delete on the cells log.
        guard let selected = cell as? WellTrackTableViewCell else {
            return false
        }
        self.removeFromFirebase(key: selected.log?.key, ref: self.databaseRef!, vals: selected.log!)
        return true
    }
}

extension LogHistoryTableViewController: LogCreationViewDelegate {
    
    func saveLog(log: HealthLog) {
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        let vals = self.toDictionary(log: log)
        self.saveLogToFirebase(key: log.key, ref: database, vals: vals)
    }
}
