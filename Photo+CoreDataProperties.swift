//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Yang Gao on 5/1/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var id: Int64
    @NSManaged public var pin: Pin?

}
