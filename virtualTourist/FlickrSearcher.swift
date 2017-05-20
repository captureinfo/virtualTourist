//
//  FlickrSearcher.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/15/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import MapKit
import CoreData

class FlickrSearcher {
    let latitude: Double
    let longitude: Double
    let pinUuid: String
    let pin: Pin
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var nextPhotoIndex: Int
    
    var images: [UIImage?]?
    
    let LIMIT = Constants.MaxNumberOfImagesOnScreen
    
    init?(latitude: Double, longitude: Double, pinUuid: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.pinUuid = pinUuid
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Pin")
        
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", self.pinUuid)
        
        var pins: [NSManagedObject]!
        do{
            pins = try managedContext.fetch(fetchRequest)
        }catch let error as NSError {
            print("Could not fetch. \(error)")
        }
        if (pins.count == 0) {
            print("Bug: no pin found")
            return nil
        }
        self.pin = pins[0] as! Pin
        self.nextPhotoIndex = Int(pin.nextPhotoIndex)
    }
    
    func search(_ renderer: @escaping () -> ()) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                print("there is error with your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON")
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                print("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                print("No Photos Found. Search Again.")
                return
            } else {
                self.images = [UIImage?](repeating: nil, count: min(photosArray.count, self.LIMIT))
                var photoIndex = self.nextPhotoIndex
                while photoIndex < self.nextPhotoIndex + self.LIMIT && photoIndex < photosArray.count {
                    let photoDictionary = photosArray[photoIndex] as [String: AnyObject]
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                        return
                    }
                    
                    // if an image exists at the url, set the image and title
                    let imageURL = URL(string: imageUrlString)
                    guard let imageData = try? Data(contentsOf: imageURL!) else {
                        print("Image does not exist at \(imageURL)")
                        return
                    }
                    
                    self.images![photoIndex - self.nextPhotoIndex] = UIImage(data: imageData)!
                    let managedContext = self.appDelegate.persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedContext)
                    let photo = NSManagedObject(entity: entity!, insertInto: managedContext)
                    photo.setValue(imageUrlString, forKey: "id")
                    photo.setValue(imageData, forKey: "image")
                    photo.setValue(self.pin, forKey: "pin")
                    
                    do {
                        try managedContext.save()
                    }catch let error as NSError {
                        print("Could not save \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        renderer()
                    }
                    
                    photoIndex += 1
                }
                self.nextPhotoIndex = photoIndex
                self.pin.setValue(photoIndex, forKey: "nextPhotoIndex")
            }
        }
        task.resume()
    }
    
    func deletePhotos(_ indexPaths: [Int]) {
        images = images!.enumerated().flatMap { indexPaths.contains($0.0) ? nil : $0.1 }.filter { $0 != nil }
    }
    
    private func bboxString() -> String {
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
