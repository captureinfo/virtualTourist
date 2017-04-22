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
    
    @IBOutlet weak var collectionView: UICollectionView!

    var pinLocation: CLLocationCoordinate2D!
    
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
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.flickrSearcher = FlickrSearcher(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude)
        self.flickrSearcher?.search() {
            self.collectionView.reloadData()
        }
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.NumberOfImages
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        if let image = self.flickrSearcher?.images[indexPath.item] {
            cell.imageView.image = image
        }
        return cell
    }
}
