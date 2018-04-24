//
//  PlacesSearch.swift
//  Well Track
//
//  Created by Daniel Cummings on 4/1/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces
import FirebaseDatabase

class PlacesSearch: NSObject {
    
    private var uid: String?
    private var enteredRegion: (object :LocationObject, region: CLCircularRegion)!
    private var regions: [(object :LocationObject, region:CLCircularRegion)]!
    private let dataprovider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    private let regionRadius = CLLocationDistance(100)
    var types: [String] = ["airport", "train_station", "subway_station"]
    private var locationManager: CLLocationManager!
    
    func toDictionary(place: LocationObject) -> NSMutableDictionary {
        return [
            "Name": place.name as NSString,
            "Type": place.type as NSString,
            "Lat": place.lat as NSNumber,
            "Lon": place.lon as NSNumber,
            "StartDate": (place.startDate?.iso8601)! as NSString,
            "EndDate": (place.endDate?.iso8601)! as NSString
        ]
    }
}

extension PlacesSearch: CLLocationManagerDelegate {
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        
        dataprovider.fetchPlacesNearCoordinate((locations.last?.coordinate)!, radius: searchRadius, types: types) { (places) in
            if places.isEmpty {
                print("No Places")
                return
            }
            var tempRegions = [(LocationObject, CLCircularRegion)]()
            let size = places.count > 20 ? 20: places.count
            for i in 0...(size-1) {
                print(places[i].name)
                let region = CLCircularRegion(center: places[i].coordinate, radius: self.regionRadius, identifier: places[i].name)
                self.locationManager.startMonitoring(for: region)
                let tempLocObj = LocationObject(key: "", lat: Double(places[i].coordinate.latitude), lon: Double(places[i].coordinate.longitude), name: places[i].name, type: places[i].placeType, startDate: nil, endDate: nil)
                tempRegions.append((tempLocObj, region))
            }
            self.regions = tempRegions
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter")
        locationManager.stopMonitoringSignificantLocationChanges()
        print(region.identifier)
        for (obj, reg) in self.regions {
            if reg.identifier != region.identifier {
                locationManager.stopMonitoring(for: reg)
            } else {
                enteredRegion = (obj, reg)
                enteredRegion.object.startDate = Date()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit")
        guard let enteredRegion = enteredRegion else {
            print("Exit without enter")
            locationManager.startMonitoringSignificantLocationChanges()
            return
        }
        var locationObj = enteredRegion.object
        let ref = Database.database().reference(withPath: "\(uid!)/Locations/").childByAutoId()
        locationObj.endDate = Date()
        ref.setValue(self.toDictionary(place: locationObj))
        self.regions.forEach { (object, region) in
            self.locationManager.startMonitoring(for: region)
        }
        self.enteredRegion = nil
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // sets up the location manager
    func setupLocationManager(){
        locationManager = CLLocationManager()
        regions = [(object: LocationObject, region: CLCircularRegion)]()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100
    }
    
    func turnOffLocationService() {
        locationManager.stopMonitoringSignificantLocationChanges()
        if !regions.isEmpty {
            for (_, region) in regions {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location restricted.")
        case .denied:
            print("Location access denied.")
        case .notDetermined:
            print("Location permissions not determined.")
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            print("Location service OK.")
        }
    }
    
    func startLocationServices(uid :String) {
        self.uid = uid
        locationManager.startMonitoringSignificantLocationChanges()
    }
}
