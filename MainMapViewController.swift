//
//  MainMapViewController.swift
//  VirtualTourist
//
//  Created by Manraaj Nijjar on 7/23/17.
//  Copyright © 2017 Manraaj Nijjar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MainMapViewController: UIViewController{
    
    //Create connections for the storyboard view
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var editButton: UIButton!
    
    let coreDataController = CoreDataController.sharedInstance()
    
    var selectedPin : Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the delegate to itself
        mapView.delegate = self
        
        //Create the gesture recognizer and attach it to the map view
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotationOnPress(_:)))
        longTouchRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTouchRecognizer)
        
        
        annotateMap()
    }
    
    //Activates when a long pressis done on the Map View
    func addAnnotationOnPress(_ sender: UITapGestureRecognizer) {
        
        //Gets the location on where the sender is pressed and stores it in the locationCoordinate
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        //Determines if the touch is leaving the screen or not.
        if sender.state == UIGestureRecognizerState.ended {
            coreDataController.generateCoreDataPin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, completionHandler: { (success) in
                //Completion handler determines if the operation was a success and thus chooses to save context
                if success {
                    CoreDataController.saveContext()
                    
                    //Send a request into the main thread to update the UI
                    DispatchQueue.main.async { [unowned self] in
                        self.annotateMap()
                    }
                }
            })
        }
    }
    
    //Grabs the pin data from the core data controller
    func annotateMap() {
        mapView.removeAnnotations(mapView.annotations)
        let pins = coreDataController.fetchAllPins()
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.title = "View Photos"
            print(pin.longitude)
            print(pin.latitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToCollection" {
            let viewController = segue.destination as! PinViewController
            viewController.pinForPinView = selectedPin
        }
    }

}

//Handles the delegate methods for the MainMapViewController
extension MainMapViewController: MKMapViewDelegate {
    //Create the button that allows you to move to the collection view from clicking on an annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pinId"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        let coordinateValueForPin = view.annotation?.coordinate
        print("Selected")
        print((coordinateValueForPin?.longitude)!)
        print((coordinateValueForPin?.latitude)!)
        self.selectedPin = coreDataController.fetchPinForCoords(valueForLongitude: (coordinateValueForPin?.longitude)!, valueForLatitude: (coordinateValueForPin?.latitude)!, marginOfError: 0.0001)
        performSegue(withIdentifier: "SegueToCollection", sender: self)
    }
    
}
