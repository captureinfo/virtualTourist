//
//  CollectionViewController.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/8/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, MKMapViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var editCollectionButton: UIButton!
    
    @IBAction func editCollection(_ sender: UIButton) {
        let indexPaths = collectionView.indexPathsForSelectedItems!
        if indexPaths.count > 0 {
            self.collectionView.deleteItems(at: indexPaths)
            self.editCollectionButton.setTitle("New Collection", for: .normal)
        } else {
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
        if flickrSearcher == nil {
            return 0
        } else {
            return flickrSearcher.images.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        if let image = self.flickrSearcher?.images[indexPath.item] {
            cell.imageView.image = image
        }
        return cell
    }
}
