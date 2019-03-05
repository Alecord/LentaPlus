//
//  Tag+CoreDataClass.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/24/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Tag"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
}
