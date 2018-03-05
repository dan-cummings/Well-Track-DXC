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

class LogHistoryTableViewController: UITableViewController {
    
    var uid: String!
    fileprivate var databaseRef: DatabaseReference?
    fileprivate var storageRef: StorageReference?
    
    var tableViewData: [(sectionHeader: String, logs: HealthLog)]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var healthLogs : [HealthLog] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        databaseRef = Database.database().reference().child(id)
        self.registerForFireBaseUpdates()
        storageRef = Storage.storage().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return healthLogs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WellTrackTableViewCell

        let log = self.healthLogs[indexPath.row]
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

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoView = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LogInformation") as! LogInformationViewController
        infoView.log = self.healthLogs[indexPath.row]
        infoView.delegate = self
        self.navigationController?.pushViewController(infoView, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    fileprivate func registerForFireBaseUpdates() {
        self.databaseRef!.child("Logs").observe(.value, with: { snapshot in
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
                    let pictureURL = entry["pictureURL"] as! String
                    let hasVideo = entry["hasVideo"] as! Int
                    let videoURL = entry["videoURL"] as! String
                    tmpItems.append(HealthLog(key: key, date: date.iso8601,
                                              temperature: temperature, heartrate: heartrate,
                                              moodrating: moodrating, hasText: hasText, text: text,
                                              hasPicture: hasPicture, pictureURL: pictureURL,
                                              hasVideo: hasVideo, videoURL: videoURL))
                }
                self.healthLogs = tmpItems
                self.tableView.reloadData()
            }})
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newLogSegue" {
            if let dest = segue.destination as? LogCreationViewController {
                dest.delegate = self
            }
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".jpg")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func saveMediaFileToFirebase(log: HealthLog, type: Int, media: URL?, saveRefClosure: @escaping (String) -> ()) {
        let mediaType : String = type == 1 ? "picture" : "video"
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
    
    func toDictionary(log: HealthLog) -> NSMutableDictionary {
        return [
            "date": NSString(string: (log.date?.iso8601)!),
            "temperature": log.temperature as NSString,
            "heartrate": log.heartrate as NSString,
            "moodRating": log.moodrating as NSString,
            "hasText": log.hasText as NSNumber,
            "text": log.text! as NSString,
            "hasPicture": log.hasPicture as NSNumber,
            "pictureURL": log.pictureURL! as NSString,
            "hasVideo": log.hasVideo as NSNumber,
            "videoURL": log.videoURL! as NSString
        ]
    }
    
    func saveLogToFirebase(key: String?, ref: DatabaseReference?, vals: NSMutableDictionary) -> DatabaseReference? {
        var child: DatabaseReference?
        if let k = key {
            child = ref?.child("Logs").child(k)
            child?.setValue(vals)
        } else {
            child = ref?.child("Logs").childByAutoId()
            child?.setValue(vals)
        }
        return child
    }
}

extension LogHistoryTableViewController: LogCreationViewDelegate {
    
    func saveLog(log: HealthLog, picture: UIImage?, video: URL?) {
        guard let database = databaseRef else {
            print("Database/storage error")
            return
        }
        let vals = self.toDictionary(log: log)
        
        let logDataRef = self.saveLogToFirebase(key: log.key, ref: database, vals: vals)
        if log.hasPicture == 1 {
            do {
                let tempUrl = tempURL()
                try UIImageJPEGRepresentation(picture!, 0.8)?.write(to: tempUrl!)
                saveMediaFileToFirebase(log: log, type: 1, media: tempUrl, saveRefClosure: { (downloadURL) in
                    let vals = [
                        "pictureURL": downloadURL as NSString
                    ]
                    logDataRef?.updateChildValues(vals)
                })
            } catch {
                print(error.localizedDescription)
            }
        }
        if log.hasVideo == 1 {
            self.saveMediaFileToFirebase(log: log, type: 2, media: video, saveRefClosure: { (downloadURL) in
                let vals = [
                    "videoURL": downloadURL as NSString
                ]
                logDataRef?.updateChildValues(vals)
                })
        }
    }
}

extension Date {
    struct Formatter {
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            return formatter
        } ()
        static let iso8601: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter.init()
            formatter.timeZone = TimeZone.current
            return formatter
        } ()
    }
    
    var short: String {
        return Formatter.short.string(from: self)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromShort: Date? {
        return Date.Formatter.short.date(from: self)
    }
    
    var iso8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
}
