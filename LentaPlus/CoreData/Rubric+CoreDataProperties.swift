//
//  Rubric+CoreDataProperties.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/4/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData


extension Rubric {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rubric> {
        return NSFetchRequest<Rubric>(entityName: "Rubric")
    }

    @NSManaged public var favorite: Bool
    @NSManaged public var id: String?
    @NSManaged public var link: String?
    @NSManaged public var position: Int16
    @NSManaged public var selected: Bool
    @NSManaged public var slug: String?
    @NSManaged public var title: String?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Rubric {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
