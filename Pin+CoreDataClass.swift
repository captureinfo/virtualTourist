//
//  Pin+CoreDataClass.swift
//  virtualTourist
//
//  Created by Yang Gao on 4/12/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity:ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find pin!")
        }
    }
}
