//
//  Image+CoreDataClass.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/24/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Image"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
}
