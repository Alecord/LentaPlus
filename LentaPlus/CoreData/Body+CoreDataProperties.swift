//
//  Body+CoreDataProperties.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/4/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//
//

import Foundation
import CoreData


extension Body {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Body> {
        return NSFetchRequest<Body>(entityName: "Body")
    }

    @NSManaged public var content: String?
    @NSManaged public var position: Int16
    @NSManaged public var preview_image_url: String?
    @NSManaged public var provider: String?
    @NSManaged public var type: String?
    @NSManaged public var news: News?

}
