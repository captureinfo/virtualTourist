//
//  Photo+CoreDataClass.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/12/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(owner: String, isPhotoDeleted: Bool, id: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity:ent, insertInto: context)
            self.owner = owner
            self.isPhotoDeleted = isPhotoDeleted
            self.id = id
        } else {
            fatalError("Unable to find photo!")
        }
    }

}
