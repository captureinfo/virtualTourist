//
//  CollectionViewController.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/8/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, UICollectionViewDelegate, MKMapViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var editCollectionButton: UIButton!
    
    @IBAction func editCollection(_ sender: UIButton) {
        let indexPaths = collectionView.indexPathsForSelectedItems!
        if indexPaths.count > 0 {
            flickrSearcher.deletePhotos(indexPaths.map {$0.item})
            self.collectionView.deleteItems(at: indexPaths)
            self.editCollectionButton.setTitle("New Collection", for: .normal)
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Photo")
            fetchRequest.predicate = NSPredicate(format: "pin.uuid == %@", self.pinUuid)
            if let result = try? context.fetch(fetchRequest) {
                for object in result {
                    context.delete(object)
                }
            }
            self.flickrSearcher?.search() {
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pinLocation: CLLocationCoordinate2D!
    var pinUuid: String!
    
    var flickrSearcher: FlickrSearcher!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        super.viewDidLoad()
        let pin = MKPointAnnotation()
        pin.coordinate = pinLocation
        mapView.addAnnotation(pin)
        mapView.centerCoordinate = pinLocation
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.flickrSearcher = FlickrSearcher(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude, pinUuid: pinUuid)
        self.flickrSearcher.search() {
            self.collectionView.reloadData()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editCollectionButton.setTitle("Remove Selected Pictures",for: .normal)
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        cell.imageView.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = cell.imageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cell.imageView.addSubview(blurEffectView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        cell.imageView.subviews[cell.imageView.subviews.count - 1].removeFromSuperview()
        if collectionView.indexPathsForSelectedItems?.count == 0 {
            editCollectionButton.setTitle("New Collection",for: .normal)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if flickrSearcher == nil || flickrSearcher.urlsAndImages?[1] == nil {
            return 0
        } else {
            return flickrSearcher.urlsAndImages!.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        if let image = self.flickrSearcher?.urlsAndImages?[indexPath.item]?.1 {
            cell.imageView.image = image
        }
        return cell
    }
}
