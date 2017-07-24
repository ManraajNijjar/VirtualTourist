//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Manraaj Nijjar on 7/24/17.
//  Copyright © 2017 Manraaj Nijjar. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var pin: Pin?

}
