//
//  LentaRest.swift
//  LentaPlus
//
//  Created by Alex Cord on 3/19/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import Foundation
import Alamofire
import CoreData


class LentaRest {
    
    // Singleton
    static let instance = LentaRest()
    let headers: HTTPHeaders = [
        "User-Agent": "Lenta/1.4.2 (iPhone; iOS 10.3.2; Scale/2.00)",
        "X-Lenta-Media-Type": "1",
        "Accept-Language": "ru-RU;q=1, en-RU;q=0.9",
        "Accept": "application/json"
    ]
    
    private init() {}
    
    func loadNewsById(link: String?, completion: @escaping (_ news: News) -> Void) -> Bool {
        guard let id = getLentaId(link: link!) else {
            return true
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            var news = News()
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [News]
            if results?.count == 0 {
                print("Get news data by ID: ", id)
            } else {
                print("Navigate to saved news by ID: ", id)
                news = results?[0] ?? News()
            }
            
            // Update data
            var secure_url = link!
            secure_url = secure_url.replacingOccurrences(of: "http:", with: "https:")
            secure_url = secure_url.replacingOccurrences(of: "https://lenta.ru", with: "https://api.lenta.ru")
            if !secure_url.contains("https://api.lenta.ru") {
                return true
            }
            Alamofire.request(secure_url, method: .get, headers: headers)
                .responseJSON { response in
                    
                    guard response.result.isSuccess else {
                        print("Ошибка при запросе данных\(String(describing: response.result.error))")
                        return
                    }
                    
                    guard let json = response.result.value as? [String:AnyObject]
                        else {
                            print("Не могу перевести в JSON")
                            return
                    }
                    
                    guard let topic = json["topic"] as? [String:AnyObject]
                        else {
                            print("Не могу перевести в Topic")
                            return
                    }
                    
                    guard let headline = topic["headline"] as? [String:AnyObject]
                        else {
                            print("Не могу перевести в Topic")
                            return
                    }
                    
                    guard let info = headline["info"] as? [String:AnyObject]
                        else {
                            print("Не могу перевести в Info")
                            return
                    }
                    
                    news.id = info["id"] as? String
                    news.title = info["title"] as? String
                    news.modified = info["modified"] as! Int32
                    news.rightcol = info["rightcol"] as? String
                    news.announce = ""
                    news.readed = news.readed + 1
                    news.type = headline["type"] as? String
                    news.rubric = headline["rubric"]?["slug"] as? String
                    news.link = headline["links"]?["self"] as? String
                    
                    CoreDataManager.instance.saveContext()
                    completion(news)
            }
        } catch {
            print("Fetch Failed: \(error)")
            return true
        }
        return false
    }

    func loadNewsContent(id: String, completion: @escaping (_ news: News) -> Void) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            var news = News()
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [News]
            if results?.count == 0 {
                return false
            } else {
                news = results?[0] ?? News()
            }
            
            // Get relationship's data
            let secure_url = "https://api.lenta.ru" + id
            Alamofire.request(secure_url, method: .get, headers: headers)
                .responseJSON { response in
                    
                    guard response.result.isSuccess else {
                        print("Ошибка при запросе данных\(String(describing: response.result.error))")
                        completion(news)
                        return
                    }
                    
                    guard let json = response.result.value as? [String:AnyObject]
                        else {
                            print("Не могу перевести в JSON")
                            return
                    }
                    
                    guard let topic = json["topic"] as? [String:AnyObject]
                        else {
                            print("Не могу перевести в Topic")
                            return
                    }
                    
                    guard let headline = topic["headline"] as? [String:AnyObject]
                        else {
                            print("Не могу перевести в Topic")
                            return
                    }
                    
                    guard let info = headline["info"] as? [String:AnyObject]
                        else {
                            print("Не могу перевести в Info")
                            return
                    }
                    
                    news.id = info["id"] as? String
                    news.title = info["title"] as? String
                    news.modified = info["modified"] as! Int32
                    news.rightcol = info["rightcol"] as? String
                    news.type = headline["type"] as? String
                    news.rubric = headline["rubric"]?["slug"] as? String
                    news.link = headline["links"]?["self"] as? String
                    news.readed += 1
                    news.images = nil
                    news.bodies = nil
                    
                    CoreDataManager.instance.saveContext()
                    
                    let images = headline["title_image"] as? [String:AnyObject]
                    if (images?.count)! != 0 {
                        var imagesSet: [Image] = []
                        let image = Image()
                        image.caption = images?["caption"] as? String
                        image.credits = images?["credits"] as? String
                        image.url = images?["url"] as? String
                        image.position = 0
                        image.news = news
                        imagesSet.append(image)
                        news.images?.addingObjects(from: imagesSet)
                    }
                    
                    let bodies = topic["body"] as? [[String:AnyObject]]
                    if (bodies?.count)! != 0 {
                        var bodiesSet: [Body] = []
                        for itm in bodies! {
                            let body = Body()
                            body.type = itm["type"] as? String
                            body.position = itm["position"] as? Int16 ?? 0
                            body.content = itm["content"] as? String
                            body.preview_image_url = itm["preview_image_url"] as? String
                            body.provider = itm["provider"] as? String
                            body.news = news
                            bodiesSet.append(body)
                        }
                        news.bodies?.addingObjects(from: bodiesSet)
                    }
                    
                    CoreDataManager.instance.saveContext()
                    completion(news)
            }
        } catch {
            print("Fetch Failed: \(error)")
            return false
        }
        return true
    }
    
    func getLentaId(link: String) -> String? {
        var newsId:String? = nil
        let types = ["photo", "news", "extlink", "brief", "articles"]
        
        if link.contains("lenta.ru") {
            //url = absoluteString.replacingOccurrences(of: "http:", with: "https:")
            //url = url.replacingOccurrences(of: "https://lenta.ru", with: "https://api.lenta.ru")
            let startIndex = link.startIndex
            let endIndex = link.endIndex
            for type in types {
                if link.contains(type) {
                    let result = link.range(of: "/" + type + "/",
                                           options: NSString.CompareOptions.literal,
                                           range: startIndex..<endIndex,
                                           locale: nil)
                    if let range = result {
                        let start = range.lowerBound
                        newsId = String(link[start..<endIndex])
                    }
                    break
                }
            }
        }
        return newsId
    }
    
}
