//
//  ViewController.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/7/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import UIKit
import MapKit
import CoreData

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
            let uuid = UUID().uuidString
            annotation.title = uuid
            mapView.addAnnotation(annotation)
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
            
            let pin = NSManagedObject(entity: entity, insertInto: managedContext)
            pin.setValue(coordinate.latitude, forKey: "latitude")
            pin.setValue(coordinate.longitude, forKey: "longitude")
            pin.setValue(uuid, forKey: "uuid")
            pin.setValue(0, forKey: "nextPhotoIndex")
            do {
                try managedContext.save()
            }catch let error as NSError {
                print("Could not save \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        if let annotation = sender as? MKAnnotation {
            let photosViewController = segue.destination as! PhotosViewController
            photosViewController.pinLocation = annotation.coordinate
            photosViewController.pinUuid = annotation.title!
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editMode {
            if let annotation = view.annotation {
                self.mapView.removeAnnotation(annotation)
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Pin")
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", annotation.title!!)
                let pins = try! managedContext.fetch(fetchRequest)
                managedContext.delete(pins[0])
            }
        } else {
            self.mapView.deselectAnnotation(view.annotation, animated: false)
            self.performSegue(withIdentifier: "pinDetailsSegue", sender: view.annotation)
        }
    }
}

