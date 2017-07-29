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
    
    var pinForPinView: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
