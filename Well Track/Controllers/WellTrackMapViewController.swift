//
//  WellTrackMapViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/8/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class WellTrackMapViewController: UIViewController {

    var tableView: WellTrackMapTableViewController!
    var mapView: GoogleMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? WellTrackMapTableViewController {
            tableView = dest
            dest.delegate = self
        }
        if let dest = segue.destination as? GoogleMapViewController {
            mapView = dest
        }
    }

}

extension WellTrackMapViewController: MapTableViewDelegate {
    
    func displaySelectedLocations(locations: [LocationObject]) {
        mapView.updateMarkers(locations)
    }
    
    func locationSelected(location: LocationObject) {
        mapView.focusCamera(onLocation: location)
    }
}
