//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/12/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var id: String?
    @NSManaged public var owner: String?
    @NSManaged public var isPhotoDeleted: Bool
    @NSManaged public var pin: Pin?

}
