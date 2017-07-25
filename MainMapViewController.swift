//
//  MainMapViewController.swift
//  VirtualTourist
//
//  Created by Manraaj Nijjar on 7/23/17.
//  Copyright © 2017 Manraaj Nijjar. All rights reserved.
//

import UIKit
import MapKit

class MainMapViewController: UIViewController {
    
    //Create connections for the storyboard view
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var editButton: UIButton!
    
    let coreDataController = CoreDataController.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the gesture recognizer and attach it to the map view
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotationOnPress(_:)))
        longTouchRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTouchRecognizer)
        
    }
    
    //Activates when a long pressis done on the Map View
    func addAnnotationOnPress(_ sender: UITapGestureRecognizer) {
        
        //Gets the location on where the sender is pressed and stores it in the locationCoordinate
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        if sender.state == UIGestureRecognizerState.ended {
            coreDataController.generateCoreDataPin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        }
    }
    
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
    }
    
    
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
