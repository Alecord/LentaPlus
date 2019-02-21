//
//  ReadViewController.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/11/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import UIKit
import ImageSlideshow
import Alamofire

class ReadViewController: UIViewController {
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var titleNews: UILabel!
    @IBOutlet weak var textNews: UILabel!
    @IBOutlet weak var dateNews: UILabel!
    @IBOutlet weak var rubricNews: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myView: UIView!
    
    var newsFeed: FeedResponse?
    var kingfisherSource = [KingfisherSource]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleNews.text = newsFeed?.infoTitle ?? "Без заголовка"
        textNews.text = newsFeed?.infoRightcol ?? ""
        dateNews.text = newsFeed?.infoTime ?? "Сегодня"
        rubricNews.text = newsFeed?.rubricTitle ?? "Новое"
        
        
        //print()
        //imageSlideshow.frame = CGRect(x: 0.0, y: 0.0, width: imageSlideshow.bounds.size.height, height: 0)
        heightConstraint.constant = 0
        myView.layoutIfNeeded()

        // Get Article
        guard var secure_url = newsFeed?.linksSelf else {
            return
        }
        
        secure_url = secure_url.replacingOccurrences(of: "http:", with: "https:")
        let headers: HTTPHeaders = [
            "User-Agent": "Lenta/1.4.2 (iPhone; iOS 10.3.2; Scale/2.00)",
            "X-Lenta-Media-Type": "1",
            "Accept-Language": "ru-RU;q=1, en-RU;q=0.9",
            "Accept": "application/json"
        ]

        Alamofire.request(secure_url, method: .get, headers: headers)
            .downloadProgress { progress in
                //self.progressBar.progress = Float(progress.fractionCompleted)
            }
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    print("Ошибка при запросе данных\(String(describing: response.result.error))")
                    return
                }
                
                guard let json = response.result.value as? [String:AnyObject]
                    else {
                        print("Не могу перевести в JSON 1")
                        return
                }
                
                guard let body = json["topic"]?["body"] as? [[String:AnyObject]]
                    else {
                        print("Не могу перевести в JSON 2")
                        return
                }
                
                var fullContent: String = ""
                
                for itm in body {
                    //let type = itm["type"] as! String
                    //let position = itm["position"] as! Int
                    let content = itm["content"] as? String
                    if content != nil {
                        fullContent.append(content! + "\n\n")
                    }
                }
                self.textNews.text = fullContent.stripHTML
                
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                    //self.tableView.isHidden = false
                }
        }
    
        guard let imageUrl = newsFeed?.imageUrl else {
            return
        }
        //imageSlideshow.frame = CGRect(x: 0.0, y: 0.0, width: imageSlideshow.bounds.size.height, height: 300.0)
        heightConstraint.constant = 300
        myView.layoutIfNeeded()
        
        kingfisherSource.append(KingfisherSource(urlString: imageUrl)!)
        //slideshow.slideshowInterval = 5.0
        imageSlideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        imageSlideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        imageSlideshow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        imageSlideshow.activityIndicator = DefaultActivityIndicator()
        imageSlideshow.currentPageChanged = { page in
            print("current page:", page)
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        imageSlideshow.setImageInputs(kingfisherSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageSlideshow.addGestureRecognizer(recognizer)

        
        //self.navigationController?.navigationBar.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.title = ""
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""    // remove title from back button
        
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.view.backgroundColor = .clear
        
    }
    
    @objc func didTap() {
        let fullScreenController = imageSlideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }


}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    public var stripHTML: String {
        let str = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return str
    }
    
}
