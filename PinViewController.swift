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
    
    var pinForPinView: Pin!
    
    var photoSet : [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        collectionView.dataSource = self
        collectionView.delegate = self
        adjustFlowLayout(viewSize: view.frame.size)
        photoSet = Array(pinForPinView.photos as! Set<Photo>)
        print(photoSet.count)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}

extension PinViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let currentPhoto = photoSet[indexPath.row]
        
        cell.label.text = "Loading..."
        
        if currentPhoto.photo == nil {
            coreDataController.fetchImageForPhoto(photo: currentPhoto, completionHandlerForFetch: { (success) in
                //Completion handler determines if the operation was a success and thus chooses to save context
                if success {
                    CoreDataController.saveContext()
                    //Send a request into the main thread to update the UI
                    DispatchQueue.main.async { [unowned self] in
                        cell.imageView.image = UIImage(data:currentPhoto.photo! as Data,scale:1.0)
                    }
                } else {
                    DispatchQueue.main.async { [unowned self] in
                        cell.label.text = "Failed"
                    }
                }
            })
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
}
