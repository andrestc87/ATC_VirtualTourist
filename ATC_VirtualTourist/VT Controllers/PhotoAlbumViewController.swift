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
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionVIew: UICollectionView!
    @IBOutlet weak var newColletionButton: UIButton!
    
    var savedPhotos = [Photo]()
    var flickrPhotos = [FlickrPhoto]()
    var annotation: MKAnnotation!
    var selectedPin = Pin()
    var flickrClient = FlickrClient()
    var dataController: DataController!
    var flickrUtil = FlickrUtil()
    var initialPage = 0
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionVIew.delegate = self
        photoCollectionVIew.dataSource = self
        // Configures the Map
        configureMapView()
        // Disabling the Button by default
        newColletionButton.isEnabled = false
        // Sets the selected annotation on the map
        setAnnotationOnMap()
        
        // First we verify if the selected Pin has photos
        let savedPhotos = getStoredPhotosForPin()
        if savedPhotos!.count > 0 {
            print("Load Saved Photos")
            self.savedPhotos = savedPhotos!
            self.photoCollectionVIew.performBatchUpdates(nil) { (results) in
                self.newColletionButton.isEnabled = true
            }
        } else {
            print("Retrieving Photos from FLICKR")
            getPhotosForPin(page: self.initialPage)
        }
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
    
    func getPhotosForPin(page: Int) {
        FlickrClient.flickrClientSharedInstance.searchFlickrPhotos(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, page: page) { (results, error) in
            
            self.flickrPhotos = results ?? []
            
            if (self.flickrPhotos.count == 0) {
                self.photoCollectionVIew.setEmptyMessage("No Images")
            } else {
                DispatchQueue.main.async {
                    self.savePhotosForPin(photos: self.flickrPhotos)
                    self.photoCollectionVIew.reloadData()
                    self.photoCollectionVIew.restore()
                    self.photoCollectionVIew.performBatchUpdates(nil) { (results) in
                        self.newColletionButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    func savePhotosForPin(photos: [FlickrPhoto]){
        for flickrPhoto in photos {
            print(flickrPhoto.photoURLString())
            let photo = Photo(context: self.dataController.viewContext)
            photo.url = flickrPhoto.photoURLString()
            photo.pin = self.selectedPin
            self.savedPhotos.append(photo)
            try? self.dataController.viewContext.save()
        }
    }
    
    func getStoredPhotosForPin() -> [Photo]? {
        var photosArray: [Photo] = []
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.selectedPin)
        
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<photoCount {
                photosArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)))
            }
        } catch {
            print("error performing fetch")
        }
        
        return photosArray
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        deleteFlickrPhotos()
        self.savedPhotos = []
        self.initialPage += 1
        getPhotosForPin(page: self.initialPage)
    }
    
    func deleteFlickrPhotos() {
        for photo in self.savedPhotos {
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.savedPhotos.count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrPhotoViewCell", for: indexPath) as! FlickrCollectionViewCell
        
        let photo = self.savedPhotos[indexPath.row]
        cell.imageView.image = UIImage(named: "placeholderImage")
        
        if photo.imageData != nil {
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: photo.imageData! as Data)
            }
        } else {
            DispatchQueue.main.async {
                self.flickrUtil.downloadedFlickrImageToCell(photo: photo, dataController: self.dataController, cell: cell)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let photo = self.savedPhotos[indexPath.row]
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure yo want to delete this photo?", preferredStyle: .alert)

        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            self?.savedPhotos.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            self?.dataController.viewContext.delete(photo)
            try? self?.dataController.viewContext.save()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: UICollectionView extension
extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
