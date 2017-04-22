//
//  ViewController.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/7/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var popupView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var editMode = false
    
    override func viewDidLayoutSubviews() {
        // TODO
        popupView.center.y += popupView.frame.height
    }
    
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        editMode = !editMode
        if (editMode) {
            sender.title = "Done"
            UIView.animate(withDuration: 0.2, animations: {
                self.mapView.center.y -= self.popupView.frame.height
                self.popupView.center.y -= self.popupView.frame.height
            })
        } else {
            sender.title = "Edit"
            UIView.animate(withDuration: 0.2, animations: {
                self.mapView.center.y += self.popupView.frame.height
                self.popupView.center.y += self.popupView.frame.height
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(handlePress))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func handlePress(gestureReconizer: UILongPressGestureRecognizer) {
        if (gestureReconizer.state == .began) {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        if let annotation = sender as? MKAnnotation {
            (segue.destination as! PhotosViewController).pinLocation = annotation.coordinate
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editMode {
            if let annotation = view.annotation {
                self.mapView.removeAnnotation(annotation)
            }
        } else {
            self.performSegue(withIdentifier: "pinDetailsSegue", sender: view.annotation)
        }
    }
}

