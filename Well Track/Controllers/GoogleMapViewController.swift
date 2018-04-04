//
//  GoogleMapViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/4/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import GoogleMaps

/// View Controller for the google map view to display location information for visited locations.
class GoogleMapViewController: UIViewController {

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var markerList: [GMSMarker] = []
    var zoomLevel: Float = 15.0
    var objectFocus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView = GMSMapView.map(withFrame: view.bounds, camera: GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.60, zoom: zoomLevel))
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = mapView
        mapView.isHidden = true
    }
    
    /// Helper function to take a list of location objects and populate the google map with markers. This function clears all markup on the map.
    ///
    /// - Parameter marks: Collection of Location objects to add to the google map.
    func updateMarkers(_ marks: [LocationObject]) {
        
        if marks.isEmpty {
            return
        }
        
        mapView.clear()
        let path = GMSMutablePath()
        for location in marks {
            let mark = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon))
            mark.title = location.name
            mark.map = mapView
            path.add(CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon))
        }
        let polyline = GMSPolyline(path: path)
        let gradient = GMSStrokeStyle.gradient(from: .red, to: .blue)
        polyline.spans = [GMSStyleSpan(style: gradient)]
        polyline.map = mapView
    }
    
    func clearMarkers() {
        mapView.clear()
        objectFocus = false
    }
    
    func focusCamera(onLocation: LocationObject) {
        let camera = GMSCameraPosition.camera(withLatitude: onLocation.lat, longitude: onLocation.lon, zoom: zoomLevel)
        mapView.animate(to: camera)
        objectFocus = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension GoogleMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        if objectFocus {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location restricted.")
        case .denied:
            print("Location access denied.")
            mapView.isHidden = true
        case .notDetermined:
            print("Location permissions not determined.")
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            print("Location service OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("error: \(error.localizedDescription)")
    }
}
