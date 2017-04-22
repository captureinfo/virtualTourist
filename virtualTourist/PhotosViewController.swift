//
//  CollectionViewController.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/8/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pinLocation: CLLocationCoordinate2D?
    
    var flickrSearcher : FlickrSearcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.flickrSearcher = FlickrSearcher(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude)
        self.flickrSearcher?.search() {
            self.collectionView.reloadData()
        }
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        if (self.flickrSearcher!.images.count > indexPath.item) {
            let image = self.flickrSearcher?.images[indexPath.item]
            cell.image = UIImageView(image: image)
        }
        return cell
    }
}
