//
//  News+CoreDataClass.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/24/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData

@objc(News)
public class News: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "News"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
}
