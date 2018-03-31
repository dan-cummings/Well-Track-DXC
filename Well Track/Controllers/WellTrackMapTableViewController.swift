//
//  WellTrackMapTableViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/8/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import FirebaseDatabase
import FirebaseAuth
import GooglePlaces

protocol MapTableViewDelegate {
    func displaySelectedLocations(locations: [LocationObject])
    func locationSelected(location: LocationObject)
}

class WellTrackMapTableViewController: UITableViewController {

    var delegate: MapTableViewDelegate!
    var ref: DatabaseReference!
    var placesClient: GMSPlacesClient!
    var tableViewData: [(sectionHeader: String, locations: [LocationObject])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user else {
                return
            }
            self.registerForFirebase(uid: user.uid)
        }
        placesClient = GMSPlacesClient.shared()
    }
    
    func registerForFirebase(uid: String) {
        ref = Database.database().reference(withPath: "\(uid)/Locations")
        ref.observe(.value, with: { (snapshot) in
            if let values = snapshot.value as? [String : AnyObject] {
                var tmpItems = [LocationObject]()
                for (_,val) in values.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    let key = val.0
                    let lat = entry["Lat"] as! Double
                    let lon = entry["Lon"] as! Double
                    let name = entry["Name"] as! String
                    let placeID = entry["PlaceID"] as! String
                    let type = entry["Type"] as! String
                    let date = entry["Date"] as! String
                    
                    tmpItems.append(LocationObject(key: key, lat: lat, lon: lon, placeID: placeID, name: name, type: type, date: date.iso8601!))
                }
                self.sortLogsIntoSections(items: tmpItems)
            }
        })
    }
        
    func sortLogsIntoSections(items: [LocationObject]) {
        var tempSorted = [String: [LocationObject]]()
        for item in items {
            if let _ = tempSorted.index(forKey:(item.date?.short)!) {
                tempSorted[(item.date?.short)!]?.append(item);
            } else {
                tempSorted[(item.date?.short)!] = [LocationObject]()
                var sectLog = [LocationObject]()
                sectLog.append(item)
                tempSorted[(item.date?.short)!] = sectLog
            }
        }
        var temp = [(sectionHeader: String, locations: [LocationObject])]()
        for (date, sectLogs) in tempSorted {
            temp.append((sectionHeader: date, locations: sectLogs))
        }
        tableViewData = temp
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        // #warning Incomplete implementation, return the number of rows
        return tableViewData?[section].locations.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! MapTableViewCell
        guard let location = tableViewData?[indexPath.section].locations[indexPath.row] else {
            return cell
        }
        cell.data = location
        cell.locTitle.text = location.name
        switch location.type {
        case "airport":
            cell.icon.image = UIImage(named: "plane")
            cell.locType.text = "Airport"
        case "food":
            cell.icon.image = UIImage(named: "food")
            cell.locType.text = "Restaurant"
        case "train_station":
            cell.icon.image = UIImage(named: "train")
            cell.locType.text = "Train Station"
        default:
            cell.icon.image = UIImage(named: "locdef")
            cell.locType.text = "Road"
        }
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red)]
        cell.rightSwipeSettings.transition = .drag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableViewData?[section].sectionHeader
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
