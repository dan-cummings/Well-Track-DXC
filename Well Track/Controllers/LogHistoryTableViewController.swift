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
import UserNotifications


/// Table view to display the users health log history. When selected the cell will give detailed information about the selected user log. The user can change the logs by editing them and new logs will be automatically added to the list. This controller facilitates the creation of new logs by conforming to the LogCreationViewDelegate protocol.
class LogHistoryTableViewController: UITableViewController {
    
    var uid: String!
    fileprivate var databaseRef: DatabaseReference?
    fileprivate var settingsRef: DatabaseReference?
    fileprivate var storageRef: StorageReference?
    var settingsRecord: Settings!
    
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
        settingsRef = Database.database().reference(withPath: "\(id)/Settings")
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
        cell.rightSwipeSettings.transition = .drag
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
        infoView.title = "Log Information"
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
                    if !snapshot.hasChild("\(key)/temperature") {
                        continue
                    }
                    let temperature = entry["temperature"] as! String
                    let date = entry["date"] as! String
                    let heartrate = entry["heartrate"] as! String
                    let moodrating = entry["moodRating"] as! String
                    let hasText = entry["hasText"] as! Int
                    let text = entry["text"] as! String
                    let hasPicture = entry["hasPicture"] as! Int
                    let hasVideo = entry["hasVideo"] as! Int
                    let hasLocation = entry["hasLocation"] as! Int
                    let latitude = entry["latitude"] as! Float
                    let longitude = entry["longitude"] as! Float
                    tmpItems.append(HealthLog(key: key, date: date.iso8601,
                                              temperature: temperature, heartrate: heartrate,
                                              moodrating: moodrating, hasText: hasText, text: text,
                                              hasPicture: hasPicture,
                                              hasVideo: hasVideo, hasLocation: hasLocation,
                                              latitude: latitude, longitude: longitude))
                }
                self.sortLogsIntoSections(tmpItems)
            }})
        
        self.settingsRef?.observeSingleEvent(of: .value, with: { snapshot in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItem = Settings()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    tmpItem.key = val.0
                    tmpItem.maxHeart = entry["maxHeart"] as? String
                    tmpItem.minHeart = entry["minHeart"] as? String
                    tmpItem.maxTemp = entry["maxTemp"] as? String
                    tmpItem.minTemp = entry["minTemp"] as? String
                    tmpItem.alert = entry["alert"] as! Int
                }
                self.settingsRecord = tmpItem
            }
        })
    }
    
    /// Method to provide a new ondevice URL to store a jpg.
    ///
    /// - Returns: Returns a URL optional containing a new URL path. If no path available, it returns nil.
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
            "hasLocation": log.hasLocation as NSNumber,
            "latitude": log.latitude! as NSNumber,
            "longitude": log.longitude! as NSNumber

        ]
    }
    
    func toDictionary(media: MediaItems) -> NSMutableDictionary {
        return [
            "imageURL": media.imageURL! as NSString,
            "videoURL": media.videoURL! as NSString,
            "duration": media.duration! as NSNumber
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
    
    /// Function either updates or creates a firebase entry for the passed dictionary.
    ///
    /// - Parameters:
    ///   - key: The key for the firebase entry, if nil a new entry is created.
    ///   - ref: The database reference where the entry will be stored.
    ///   - vals: The dictionary containing the health log values.
    /// - Returns: Reference to the entry that was created or updated.
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
    
    func saveMediaFileToFirebase(type: Int, media: URL?, saveRefClosure: @escaping (String) -> ()) {
        let mediaType : String = type == 1 ? "Photos" : "Videos"
        let ext : String = type == 1 ? "jpg" : "mp4"
        let mime : String = type == 1 ? "image/jpeg" : "video/mp4"
        
        do {
            let media = try Data(contentsOf: media!)
            let mediaPath = "\(self.uid!)/\(mediaType)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).\(ext)"
            let metadata = StorageMetadata()
            metadata.contentType = mime
            if let storageRef = self.storageRef {
                storageRef.child(mediaPath).putData(media, metadata: metadata) {(metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error.localizedDescription)")
                        return
                    }
                    saveRefClosure(metadata!.downloadURL()!.absoluteString)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addVideoToFirebase(_ item: MediaItems, _ ref: DatabaseReference) {
        var mediaItem = MediaItems()
        mediaItem.key = ref.childByAutoId().key
        let image = imageCache.object(forKey: item.imageURL as AnyObject)
        let tempurl = tempURL()
        do {
            try UIImageJPEGRepresentation(image as! UIImage, 0.8)?.write(to: tempurl!)
        } catch { }
        self.saveMediaFileToFirebase(type: 1, media: tempurl, saveRefClosure: { (photoURL) in
            mediaItem.imageURL = photoURL
            self.saveMediaFileToFirebase(type: 0, media: videoCache.object(forKey: item.videoURL as AnyObject) as? URL, saveRefClosure: { (videoURL) in
                mediaItem.videoURL = videoURL
                let vals = self.toDictionary(media: mediaItem)
                ref.child(mediaItem.key!).setValue(vals)
            })
        })
    }
    
    func addPhotoToFirebase(_ item: MediaItems, _ ref: DatabaseReference) {
        var mediaItem = MediaItems()
        mediaItem.key = ref.childByAutoId().key
        let image = imageCache.object(forKey: item.imageURL as AnyObject)
        let tempurl = tempURL()
        do {
            try UIImageJPEGRepresentation(image as! UIImage, 0.8)?.write(to: tempurl!)
        } catch { }
        self.saveMediaFileToFirebase(type: 1, media: tempurl, saveRefClosure: { (downloadURL) in
            mediaItem.imageURL = downloadURL
            let vals = self.toDictionary(media: mediaItem)
            ref.child(mediaItem.key!).setValue(vals)
        })
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
    
    func saveLog(log: HealthLog, images: [MediaItems]?, videos: [MediaItems]?) {
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        
        let vals = self.toDictionary(log: log)
        self.saveLogToFirebase(key: log.key, ref: database, vals: vals)
        if let uploadImage = images {
            let imageRef = database.child("\(log.key!)/Pictures")
            for image in uploadImage {
                if let _ = image.key {
                    continue
                } else {
                    self.addPhotoToFirebase(image, imageRef)
                }
            }
        }
        
        if let uploadVideo = videos {
            let videoRef = database.child("\(log.key!)/Videos")
            for video in uploadVideo {
                if let _ = video.key {
                    continue
                } else {
                    self.addVideoToFirebase(video, videoRef)
                }
            }
        }
        
        let currentDate = Date()
        // Check whether to send notification if user wants notifications and the log is from current day
        if (settingsRecord.alert == 1) && (Calendar.current.isDate(log.date!, inSameDayAs: currentDate)) {
            self.checkRanges(log: log)
        }
    }
    
    // Checks the values in new log against settings
    func checkRanges(log: HealthLog) {
        // hold settings to compare against value of log being added
        var maxHeart: Double
        var minHeart: Double
        var maxTemp: Double
        var minTemp: Double
        
        // Convert values from strings to doubles, set to -1 if empty
        print("Max heart should be: \(settingsRecord.maxHeart ?? "not found")")
        let maxHeartVal = settingsRecord.maxHeart ?? "-1"
        let minHeartVal = settingsRecord.minHeart ?? "-1"
        let maxTempVal = settingsRecord.maxTemp ?? "-1"
        let minTempVal = settingsRecord.minTemp ?? "-1"
        maxHeart = Double(maxHeartVal)!
        minHeart = Double(minHeartVal)!
        maxTemp = Double(maxTempVal)!
        minTemp = Double(minTempVal)!
        
        // get the numbers from the log being created
        let tempArray = log.temperature.components(separatedBy: " ")
        let heartArray = log.heartrate.components(separatedBy: " ")
        
        // check if log values are inside setting boundaries
        if let temp = Double(tempArray[0]) {
            if (maxTemp > -1.0) && (temp > maxTemp) {
                sendNotification(reason: "temp", direction: "over", value: maxTemp)
            }
            else if (minTemp > -1.0) && (temp < minTemp) {
                sendNotification(reason: "temp", direction: "under", value: minTemp)
            }
        }
        else {
            print("Can't convert temp")
        }
        if let rate = Double(heartArray[0]) {
            if (maxHeart > -1.0) && (rate > maxHeart) {
                sendNotification(reason: "heartrate", direction: "over", value: maxHeart)
            }
            if (minHeart > -1.0) && (rate < minHeart) {
                sendNotification(reason: "heartrate", direction: "under", value: minHeart)
            }
        }
        else {
            print("Can't convert heartrate")
        }
    }
    
    // Creates a set of notifications given a reason, direction, and threshold value
    func sendNotification(reason: String, direction: String, value: Double) {
        var unit: String
        // Checks reason in order to determine unit
        if reason == "temp" {
            unit = "degrees"
        }
        else {
            unit = "bpm"
        }
        // Creates the first, immediate notification alerting the user that some data is outside range
        let content = UNMutableNotificationContent()
        content.title = "Alert"
        content.body = "Your \(reason) is \(direction) \(value) \(unit). Reminder set for 1 hour."
        content.sound = UNNotificationSound.default()
        // Will notify user 1 second after log is saved
        var trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request1 = UNNotificationRequest(identifier: "Initial", content: content, trigger: trigger)
        
        // Adds initial notification
        UNUserNotificationCenter.current().add(request1, withCompletionHandler: nil)
        
        // Creates second, delayed notification
        content.title = "Time to check in!"
        content.body = "An hour ago, your \(reason) was \(direction) \(value) \(unit)."
        // Sets delay, will want to change to 1 hour when not testing/demoing
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        
        let request2 = UNNotificationRequest(identifier: "Delayed", content: content, trigger: trigger)
        // Adds second notification
        UNUserNotificationCenter.current().add(request2, withCompletionHandler: nil)
        
    }
}
