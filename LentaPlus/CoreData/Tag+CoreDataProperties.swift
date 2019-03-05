//
//  Tag+CoreDataProperties.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/4/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var position: Int16
    @NSManaged public var slug: String?
    @NSManaged public var title: String?
    @NSManaged public var news: News?
    @NSManaged public var rubric: Rubric?

}
