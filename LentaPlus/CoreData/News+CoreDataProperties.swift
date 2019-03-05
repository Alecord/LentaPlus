//
//  News+CoreDataProperties.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/4/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News")
    }

    @NSManaged public var announce: String?
    @NSManaged public var favotite: Bool
    @NSManaged public var id: String?
    @NSManaged public var latest: Bool
    @NSManaged public var link: String?
    @NSManaged public var modified: Int32
    @NSManaged public var popular: Bool
    @NSManaged public var readed: Int16
    @NSManaged public var rightcol: String?
    @NSManaged public var rubric: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var bodies: NSSet?
    @NSManaged public var images: NSSet?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for bodies
extension News {

    @objc(addBodiesObject:)
    @NSManaged public func addToBodies(_ value: Body)

    @objc(removeBodiesObject:)
    @NSManaged public func removeFromBodies(_ value: Body)

    @objc(addBodies:)
    @NSManaged public func addToBodies(_ values: NSSet)

    @objc(removeBodies:)
    @NSManaged public func removeFromBodies(_ values: NSSet)

}

// MARK: Generated accessors for images
extension News {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension News {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
