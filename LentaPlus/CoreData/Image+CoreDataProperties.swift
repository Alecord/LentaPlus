//
//  Image+CoreDataProperties.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/4/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var caption: String?
    @NSManaged public var credits: String?
    @NSManaged public var position: Int16
    @NSManaged public var source: NSData?
    @NSManaged public var url: String?
    @NSManaged public var news: News?

}
