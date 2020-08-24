//
//  MapViewController.swift
//  ATC_VirtualTourist
//
//  Created by andres tello campos on 8/23/20.
//  Copyright © 2020 andres tello campos. All rights reserved.
//

import UIKit
import MapKit

let userDefaultLatitudeKey = "latitude"
let userDefaultLatitudeDeltaKey = "latitudeDelta"
let userDefaultLongitudeKey = "longitude"
let userDefaultLongitudeDeltaKey = "longitudeDelta"

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        view.addGestureRecognizer(longPressGesture)
        
        // Verifies if there is map information saved to navigate the user to the saved position on the map
        if (UserDefaults.standard.value(forKey: userDefaultLatitudeKey) != nil) {
            loadSavedMapPosition()
        } else {
            print("No map information saved.")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Guardar Defaults")
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            print("Add Pin")
            
            let locationPoint = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(locationPoint, toCoordinateFrom: mapView)
            print("You tapped at: \(locationCoordinate.latitude), \(locationCoordinate.longitude)")
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.coordinate = locationCoordinate
            locationAnnotation.title = "View Photos"
            mapView.addAnnotation(locationAnnotation)
            
        }
        
    }
    
    //MapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationId = "mapPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .blue
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            print("Pin Tapped")
            saveMapPosition()
            
        }
    }
    
    func saveMapPosition() {
        let mapRegionSpan = mapView.region.span
        let mapCoordinates = mapView.centerCoordinate
        let userDeaults = UserDefaults.standard
        userDeaults.set(mapCoordinates.latitude, forKey: userDefaultLatitudeKey)
        userDeaults.set(mapCoordinates.longitude, forKey: userDefaultLongitudeKey)
        userDeaults.set(mapRegionSpan.latitudeDelta, forKey: userDefaultLatitudeDeltaKey)
        userDeaults.set(mapRegionSpan.longitudeDelta, forKey: userDefaultLongitudeDeltaKey)
        print("Data Saved")
    }
    
    func loadSavedMapPosition() {
        DispatchQueue.main.async {
            let userDefaults = UserDefaults.standard
            let savedLatitude = userDefaults.double(forKey: userDefaultLatitudeKey)
            let savedLongitude = userDefaults.double(forKey: userDefaultLongitudeKey)
            let savedLatitudeDelta = userDefaults.double(forKey: userDefaultLatitudeDeltaKey)
            let savedLongitudeDelta = userDefaults.double(forKey: userDefaultLongitudeDeltaKey)
            
            let savedMapCoordinate = CLLocationCoordinate2D(latitude: savedLatitude, longitude: savedLongitude)
            let savedMapSpan = MKCoordinateSpan(latitudeDelta: savedLatitudeDelta, longitudeDelta: savedLongitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: savedMapCoordinate, span: savedMapSpan)
            self.mapView.setRegion(savedRegion, animated: true)
        }
    }
    
}
