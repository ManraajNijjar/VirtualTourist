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
        print(pinForPinView.latitude)
        print(pinForPinView.longitude)
        // Do any additional setup after loading the view.
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
