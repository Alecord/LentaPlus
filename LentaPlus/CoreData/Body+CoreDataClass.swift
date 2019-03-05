//
//  Body+CoreDataClass.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/1/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Body)
public class Body: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Body"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
}
