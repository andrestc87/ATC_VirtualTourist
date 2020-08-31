//
//  PhotoAlbumViewController.swift
//  ATC_VirtualTourist
//
//  Created by andres tello campos on 8/30/20.
//  Copyright © 2020 andres tello campos. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionVIew: UICollectionView!
    @IBOutlet weak var newColletionButton: UIButton!
    
    var annotation : MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configures the Map
        configureMapView()
        // Disabling the Button by default
        newColletionButton.isEnabled = false
        // Sets the selected annotation on the map
        setAnnotationOnMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configureMapView() {
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isUserInteractionEnabled = false
        mapView.isScrollEnabled = false
    }
    
    func setAnnotationOnMap() {
        let spanAnnotation = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let annotationMapRegion = MKCoordinateRegion(center: annotation.coordinate, span: spanAnnotation)
        mapView.setRegion(annotationMapRegion, animated: true)
        
        self.mapView.addAnnotation(annotation)
    }
    
    //MapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationId = "mapPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = false
            pinView?.pinTintColor = .blue
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}
