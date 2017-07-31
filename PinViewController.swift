//
//  PinViewController.swift
//  VirtualTourist
//
//  Created by Manraaj Nijjar on 7/27/17.
//  Copyright © 2017 Manraaj Nijjar. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let coreDataController = CoreDataController.sharedInstance()
    
    let queue = DispatchQueue(label: "com.appcoda.myqueue")
    
    var pinForPinView: Pin!
    
    var photoSet : [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        collectionView.dataSource = self
        collectionView.delegate = self
        adjustFlowLayout(viewSize: view.frame.size)
        photoSet = Array(pinForPinView.photos as! Set<Photo>)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustFlowLayout(viewSize: size)
    }
    
    func adjustFlowLayout(viewSize: CGSize) {
        let space:CGFloat = 3.0
        let dimension: CGFloat = viewSize.width >= viewSize.height ? (viewSize.width - (5 * space)) / 6.0 : (viewSize.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    //Sets up the map view properly. Called when the view loads
    func mapSetup(){
        let mapCenter = CLLocationCoordinate2D(latitude: pinForPinView.latitude, longitude: pinForPinView.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: mapCenter, span: span)
        mapView.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCenter
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        for photo in photoSet {
            coreDataController.deletePhoto(photo: photo, completionHandlerForDelete: {})
        }
        
        CoreDataController.saveContext()
        
        coreDataController.refreshPinData(pinForRefresh: pinForPinView) { (success) in
            CoreDataController.saveContext()
            self.photoSet = Array(self.pinForPinView.photos as! Set<Photo>)
            self.collectionView.reloadData()
        }
    }
    
    
}




extension PinViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoSet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let currentPhoto = photoSet[indexPath.row]
        
        cell.label.text = "Loading..."
        
        queue.async {
            if currentPhoto.photo == nil {
                self.coreDataController.fetchImageForPhoto(photo: currentPhoto, completionHandlerForFetch: { (success) in
                    //Completion handler determines if the operation was a success and thus chooses to save context
                    if success {
                        CoreDataController.saveContext()
                        //Send a request into the main thread to update the UI
                        DispatchQueue.main.async { [unowned self] in
                            cell.imageView.image = UIImage(data:currentPhoto.photo! as Data,scale:1.0)
                            cell.label.text = " "
                        }
                    } else {
                        DispatchQueue.main.async { [unowned self] in
                            cell.label.text = "Failed"
                        }
                    }
                })
            } else {
                DispatchQueue.main.async { [unowned self] in
                    cell.imageView.image = UIImage(data:currentPhoto.photo! as Data,scale:1.0)
                    cell.label.text = " "
                }
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coreDataController.deletePhoto(photo: photoSet[indexPath.row], completionHandlerForDelete: {
            CoreDataController.saveContext()
            pinForPinView = coreDataController.fetchPinForCoords(valueForLongitude: pinForPinView.longitude, valueForLatitude: pinForPinView.latitude, marginOfError: 0.00001)
            photoSet = Array(pinForPinView.photos as! Set<Photo>)
            collectionView.reloadData()
            
        })
    }
    
    
}
