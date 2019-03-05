import UIKit
import SnapKit
import CoreData
import Alamofire
import SwiftSoup

class StretchyViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let newsTitle = UILabel()
    private let timeTitle = UILabel()
    private let rubricTitle = UILabel()
    private let imageView = UIImageView()
    private let textContainer = UIView()
    private let separatorContainer = UIImageView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
    private let news: News
    var bodies: [Body]!
    
    init(news: News) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent(url: news.link!)
        viewConfiguration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(hue: 100, saturation: 100, brightness: 100, alpha: 0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            scrollView.scrollIndicatorInsets = view.safeAreaInsets
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func viewConfiguration() -> Void {
        view.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        scrollView.delegate = self
        
        // Image configuration
        imageView.image = UIImage(named: "Header")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if (news.images?.count)! > 0 {
            for item in (news.images)! {
                let image = item as! Image
                let url = image.url ?? ""
                if url != "" {
                    loadImage(url: url, place: imageView)
                    break
                }
            }
        }
        
        // Time configuration
        timeTitle.textColor = UIColor.secondColor
        timeTitle.font = UIFont(name: "PTRootUI-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        timeTitle.numberOfLines = 0
        timeTitle.text = CoreDataManager.instance.GetTimeLocalosated(modified: Double(news.modified))
        
        // Separator
        separatorContainer.image = UIImage(named: "Circle")
        separatorContainer.contentMode = .scaleAspectFit
        separatorContainer.clipsToBounds = true

        // Rubric configuration
        rubricTitle.textColor = .gray
        rubricTitle.font = UIFont(name: "PTRootUI-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        rubricTitle.numberOfLines = 0
        let rubric: String = news.rubric ?? "Новое"
        rubricTitle.text = CoreDataManager.instance.GetRubricTitle(name: rubric)

        // Title configuration
        newsTitle.textColor = .black
        newsTitle.font = UIFont(name: "PTRootUI-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        newsTitle.numberOfLines = 0
        newsTitle.text = news.title

        // Containers configuration
        let imageContainer = UIView()
        imageContainer.backgroundColor = .white
        
        textContainer.backgroundColor = .clear
        //textContainer.addSubview(contentText)
        
        let textBacking = UIView()
        textBacking.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageContainer)
        scrollView.addSubview(textBacking)
        scrollView.addSubview(textContainer)
        scrollView.addSubview(imageView)
        scrollView.addSubview(newsTitle)
        scrollView.addSubview(timeTitle)
        scrollView.addSubview(separatorContainer)
        scrollView.addSubview(rubricTitle)

        scrollView.snp.makeConstraints {
            make in
            make.edges.equalTo(view)
        }
        
        imageContainer.snp.makeConstraints {
            make in
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.height.equalTo(imageContainer.snp.width).multipliedBy(0.7)
        }
        
        imageView.snp.makeConstraints {
            make in
            make.left.right.equalTo(imageContainer)
            make.top.equalTo(view).priority(.high)
            make.height.greaterThanOrEqualTo(imageContainer.snp.height).priority(.required)
            make.bottom.equalTo(imageContainer.snp.bottom)
        }
        
        textContainer.snp.makeConstraints {
            make in
            
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(scrollView)
        }

        timeTitle.snp.makeConstraints {
            make in
            make.left.equalTo(textContainer).offset(15)
            make.top.equalTo(textContainer).offset(15)
        }
        
        separatorContainer.snp.makeConstraints {
            make in
            make.left.equalTo(timeTitle.snp.right).offset(10)
            make.centerY.equalTo(timeTitle.snp.centerY)
            make.top.equalTo(textContainer).offset(15)
        }

        rubricTitle.snp.makeConstraints {
            make in
            make.left.equalTo(separatorContainer.snp.right).offset(10)
            make.centerY.equalTo(timeTitle.snp.centerY)
            make.top.equalTo(textContainer).offset(15)
        }
        
        newsTitle.snp.makeConstraints {
            make in
            make.width.equalTo(view).offset(-30)
            make.left.equalTo(textContainer).offset(15)
            make.right.equalTo(textContainer).offset(15)
            make.top.equalTo(timeTitle.snp.bottom).offset(10)
        }
        
        textBacking.snp.makeConstraints {
            make in
            
            make.left.right.equalTo(view)
            make.top.equalTo(textContainer)
            make.bottom.equalTo(view)
        }
        
        
    }
    
    func reloadContent(data: News) {
        let bCount: Int = data.bodies?.count ?? 0
        if bCount != 0 {
            var i = 0
            var lastTextLabel: UILabel?
            var bodies = data.bodies?.allObjects as! [Body]
            bodies = bodies.sorted(by: { $0.position < $1.position })
            for body in bodies {
                var ffont = UIFont(name: "PTRootUI-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
                if body.type == "h1" {
                    ffont = UIFont(name: "PTRootUI-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
                }
                let contentText = UILabel()
                contentText.textColor = .black
                contentText.numberOfLines = 0
                contentText.font = ffont
                contentText.attributedText = parseContent(content: body.content ?? "")
                contentText.isUserInteractionEnabled = true
                
                textContainer.addSubview(contentText)
                contentText.snp.makeConstraints {
                    make in
                    make.width.equalTo(view).offset(-30)
                    make.left.equalTo(textContainer).offset(15)
                    make.right.equalTo(textContainer).offset(15)
                    if i == 0 {
                        make.top.equalTo(newsTitle.snp.bottom).offset(15)
                    } else if i == (data.bodies?.count)!-1 {
                        make.bottom.equalTo(textContainer).offset(-15)
                        make.top.equalTo(lastTextLabel!.snp.bottom).offset(20)
                    } else {
                        make.top.equalTo(lastTextLabel!.snp.bottom).offset(20)
                    }
                }
                lastTextLabel = contentText
                i += 1
            }
            view.layoutIfNeeded()
            view.updateConstraints()
        }
    }
    
    func parseContent(content: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: content, attributes: nil)
        guard let els: Elements = try? SwiftSoup.parse(content).select("a") else { return attributedString }
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.secondColor,
            NSAttributedString.Key.underlineColor: UIColor.secondColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        for element in els.array() {
            //guard let hrefLink: String = try? element.attr("href") else { break }
            guard let textLink: String = try? element.text() else { break }
            guard let outerHtml: String = try? element.outerHtml() else { break }
            let foundRange: NSRange = (attributedString.string as NSString).range(of: outerHtml, options: .literal)
            attributedString.setAttributes(linkAttributes, range: foundRange)
            if foundRange.length > 0 {
                attributedString.mutableString.replaceOccurrences(of: outerHtml, with: textLink, options: [], range: foundRange)
            }
        }
        return attributedString
    }
    
    func loadImage(url: String, place: UIImageView) {
        let headers: HTTPHeaders = [
            "User-Agent": "Lenta/1.4.2 (iPhone; iOS 10.3.2; Scale/2.00)",
            "X-Lenta-Media-Type": "1",
            "Accept-Language": "ru-RU;q=1, en-RU;q=0.9",
            "Accept": "application/json"
        ]

        Alamofire.request(url, method: .get, headers: headers)
            .validate()
            .responseData(completionHandler: { (responseData) in
                place.image = UIImage(data: responseData.data!)
                place.contentMode = .scaleAspectFill
                place.clipsToBounds = true
                DispatchQueue.main.async {
                    // Refresh you views
                }
            })
    }
    
    func loadContent(url: String) {
        let headers: HTTPHeaders = [
            "User-Agent": "Lenta/1.4.2 (iPhone; iOS 10.3.2; Scale/2.00)",
            "X-Lenta-Media-Type": "1",
            "Accept-Language": "ru-RU;q=1, en-RU;q=0.9",
            "Accept": "application/json"
        ]
        let secure_url = url.replacingOccurrences(of: "http:", with: "https:")
        Alamofire.request(secure_url, method: .get, headers: headers)
            .validate()
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
                //print(json)
                
                guard let bodies = json["topic"]?["body"] as? [[String:AnyObject]]
                    else {
                        print("Не могу перевести в JSON 2")
                        return
                }
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
                fetchRequest.predicate = NSPredicate(format: "id = %@", (self.news.id)!)
                do {
                    let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [News]
                    if results?.count != 0 {
                        if results?[0].bodies?.count == 0 {
                            for itm in bodies {
                                let body = Body()
                                body.type = itm["type"] as? String
                                body.position = itm["position"] as? Int16 ?? 0
                                body.content = itm["content"] as? String
                                body.preview_image_url = itm["preview_image_url"] as? String
                                body.provider = itm["provider"] as? String
                                body.news = results![0]
                            }
                            CoreDataManager.instance.saveContext()
                        }
                        self.reloadContent(data: results![0] as News)
                    }
                } catch {
                    print("Fetch Failed: \(error)")
                }
                
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                }
        }
    }
    
    //MARK: - Scroll View Delegate
    
    private var previousStatusBarHidden = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if previousStatusBarHidden != shouldHideStatusBar {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
            
            previousStatusBarHidden = shouldHideStatusBar
        }
    }
    
    //MARK: - Status Bar Appearance
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    private var shouldHideStatusBar: Bool {
        let frame = textContainer.convert(textContainer.bounds, to: nil)
        if #available(iOS 11.0, *) {
            return frame.minY < view.safeAreaInsets.top
        } else {
            return  true
        }
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
