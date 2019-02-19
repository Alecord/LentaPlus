//
//  LentaModel.swift
//  LentaPlus
//
//  Created by Alex Cord on 1/30/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import Foundation
import ObjectMapper

class FeedResponse: NSObject, NSCoding, Mappable {
    var type: String?
    var infoId: String?
    var infoTitle: String?
    var infoRightcol: String?
    var infoModified: Double?
    var infoTime: String?
    var linksSelf: String?
    var linksPublic: String?
    var rubricSlug: String?
    var rubricTitle: String?
    var imageUrl: String?
    var imageCredits: String?
    var imageCaption: String?
    //var info: FeedInfo?
    
    required init?(map: Map){
    }

    required init?(coder aDecoder: NSCoder) {
        self.type = aDecoder.decodeObject(forKey: "type") as? String;
        self.infoId = aDecoder.decodeObject(forKey: "infoId") as? String;
        self.infoTitle = aDecoder.decodeObject(forKey: "infoTitle") as? String;
        self.infoRightcol = aDecoder.decodeObject(forKey: "infoRightcol") as? String;
        self.infoModified = aDecoder.decodeObject(forKey: "infoModified") as? Double;
        self.infoTime = aDecoder.decodeObject(forKey: "infoTime") as? String;
        self.linksSelf = aDecoder.decodeObject(forKey: "linksSelf") as? String;
        self.linksPublic = aDecoder.decodeObject(forKey: "linksPublic") as? String;
        self.rubricSlug = aDecoder.decodeObject(forKey: "rubricSlug") as? String;
        self.rubricTitle = aDecoder.decodeObject(forKey: "rubricTitle") as? String;
        self.imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as? String;
        self.imageCredits = aDecoder.decodeObject(forKey: "imageCredits") as? String;
        self.imageCaption = aDecoder.decodeObject(forKey: "imageCaption") as? String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.type, forKey: "type");
        aCoder.encode(self.infoId, forKey: "infoId");
        aCoder.encode(self.infoTitle, forKey: "infoTitle");
        aCoder.encode(self.infoRightcol, forKey: "infoRightcol");
        aCoder.encode(self.infoModified, forKey: "infoModified");
        aCoder.encode(self.infoTime, forKey: "infoTime");
        aCoder.encode(self.linksSelf, forKey: "linksSelf");
        aCoder.encode(self.linksPublic, forKey: "linksPublic");
        aCoder.encode(self.rubricSlug, forKey: "rubricSlug");
        aCoder.encode(self.rubricTitle, forKey: "rubricTitle");
        aCoder.encode(self.imageUrl, forKey: "imageUrl");
        aCoder.encode(self.imageCredits, forKey: "imageCredits");
        aCoder.encode(self.imageCaption, forKey: "imageCaption");
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        infoId <- map["info.id"]
        infoTitle <- map["info.title"]
        infoRightcol <- map["info.rightcol"]
        infoModified <- map["info.modified"]
        if let timeDouble = map["info.modified"].currentValue as? TimeInterval {
            let timestamp = NSDate().timeIntervalSince1970
            let mins = (timestamp - timeDouble)/60
            let date = Date(timeIntervalSince1970: timeDouble)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current //TimeZone(abbreviation: "GMT +3")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
            if mins < 60 {
                dateFormatter.dateFormat = "HH:mm"
            } else if mins < 1440 {
                dateFormatter.dateFormat = "Сегодня, HH:mm"
            }
            infoTime = dateFormatter.string(from: date)
        }
        linksSelf <- map["links.self"]
        linksPublic <- map["links.public"]
        rubricSlug <- map["rubric.slug"]
        rubricTitle <- map["rubric.title"]
        imageUrl <- map["title_image.url"]
        imageCredits <- map["title_image.credits"]
        imageCaption <- map["title_image.caption"]
        //info <- map["info"]
    }
}

class FeedInfo: Mappable {
    var id: String?
    var title: String?
    var rightcol: String?
    var modified: Double?
    var time: String?
    
    required init?(map: Map){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String;
        self.title = aDecoder.decodeObject(forKey: "title") as? String;
        self.rightcol = aDecoder.decodeObject(forKey: "rightcol") as? String;
        self.modified = aDecoder.decodeObject(forKey: "modified") as? Double;
        self.time = aDecoder.decodeObject(forKey: "time") as? String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id");
        aCoder.encode(self.title, forKey: "title");
        aCoder.encode(self.rightcol, forKey: "rightcol");
        aCoder.encode(self.modified, forKey: "modified");
        aCoder.encode(self.time, forKey: "time");
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        rightcol <- map["rightcol"]
        modified <- map["modified"]
        if let timeDouble = map["modified"].currentValue as? TimeInterval {
            let timestamp = NSDate().timeIntervalSince1970
            let mins = (timestamp - timeDouble)/60
            let date = Date(timeIntervalSince1970: timeDouble)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current //TimeZone(abbreviation: "GMT +3")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
            if mins < 60 {
                dateFormatter.dateFormat = "HH:mm"
            } else if mins < 1440 {
                dateFormatter.dateFormat = "Сегодня, HH:mm"
            }
            time = dateFormatter.string(from: date)
        }
    }
}

class FeedLinks: Mappable {
    var url: String?
    var pub: String?
    
    required init?(map: Map){
    }

    required init?(coder aDecoder: NSCoder) {
        self.url = aDecoder.decodeObject(forKey: "url") as? String;
        self.pub = aDecoder.decodeObject(forKey: "pub") as? String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.url, forKey: "url");
        aCoder.encode(self.pub, forKey: "pub");
    }
    
    func mapping(map: Map) {
        url <- map["self"]
        pub <- map["public"]
    }
}

class FeedRubric: Mappable {
    var slug: String?
    var title: String?
    
    required init?(map: Map){
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.slug = aDecoder.decodeObject(forKey: "slug") as? String;
        self.title = aDecoder.decodeObject(forKey: "title") as? String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.slug, forKey: "slug");
        aCoder.encode(self.title, forKey: "title");
    }

    func mapping(map: Map) {
        slug <- map["slug"]
        title <- map["title"]
    }
}

class FeedImage: Mappable {
    var url: String?
    var credits: String?
    var caption: String?
    
    required init?(map: Map){
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.url = aDecoder.decodeObject(forKey: "url") as? String;
        self.credits = aDecoder.decodeObject(forKey: "credits") as? String;
        self.caption = aDecoder.decodeObject(forKey: "caption") as? String;
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.url, forKey: "url");
        aCoder.encode(self.credits, forKey: "credits");
        aCoder.encode(self.caption, forKey: "caption");
    }

    func mapping(map: Map) {
        url <- map["url"]
        credits <- map["credits"]
        caption <- map["caption"]
    }
}
