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
    func clearDisplay()
}

class WellTrackMapTableViewController: UITableViewController {

    var delegate: MapTableViewDelegate!
    var ref: DatabaseReference!
    var placesClient: GMSPlacesClient!
    var expandedSectionHeaderNumber: Int = -1
    let kHeaderSectionTag: Int = 6900
    var tableViewData: [(sectionHeader: String, locations: [LocationObject])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    let type = entry["Type"] as! String
                    let startDate = entry["StartDate"] as! String
                    let endDate = entry["EndDate"] as! String
                    
                    tmpItems.append(LocationObject(key: key, lat: lat, lon: lon, name: name, type: type, startDate: startDate.iso8601!, endDate: endDate.iso8601))
                }
                self.sortLogsIntoSections(items: tmpItems)
            }
        })
    }
        
    func sortLogsIntoSections(items: [LocationObject]) {
        var tempSorted = [String: [LocationObject]]()
        for item in items {
            if let _ = tempSorted.index(forKey:(item.startDate?.short)!) {
                tempSorted[(item.startDate?.short)!]?.append(item);
            } else {
                tempSorted[(item.startDate?.short)!] = [LocationObject]()
                var sectLog = [LocationObject]()
                sectLog.append(item)
                tempSorted[(item.startDate?.short)!] = sectLog
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = .gray
        header.textLabel?.textColor = .white
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let imageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
        imageView.image = UIImage(named: "down")
        imageView.tag = kHeaderSectionTag + section
        header.addSubview(imageView)
        
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(WellTrackMapTableViewController.sectionHeaderTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    @objc func sectionHeaderTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        if self.expandedSectionHeaderNumber == -1 {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapseSection(section, imageView: eImageView!)
            } else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapseSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expandedSectionHeaderNumber == section {
            return tableViewData?[section].locations.count ?? 0
        } else {
            return 0
        }
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
        case "subway_station":
            cell.icon.image = UIImage(named: "train")
            cell.locType.text = "Subway Station"
        case "train_station":
            cell.icon.image = UIImage(named: "train")
            cell.locType.text = "Train Station"
        default:
            cell.icon.image = UIImage(named: "locdef")
            cell.locType.text = "Unknown"
        }
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red)]
        cell.rightSwipeSettings.transition = .drag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.delegate.locationSelected(location: self.tableViewData![indexPath.section].locations[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Trip on \(self.tableViewData?[section].sectionHeader ?? "")"
    }
    
    // MARK: - Expanding and collapsing cells
    
    func tableViewCollapseSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.tableViewData![section].locations
        self.expandedSectionHeaderNumber = -1
        if sectionData.count == 0 {
            return
        } else {
            UIView.animate(withDuration: 0.4) {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            }
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            self.delegate.clearDisplay()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.tableViewData![section].locations
        if sectionData.count == 0 {
            self.expandedSectionHeaderNumber = -1
            return
        } else {
            UIView.animate(withDuration: 0.4) {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            }
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            self.delegate.displaySelectedLocations(locations: sectionData)
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
