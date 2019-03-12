import UIKit
import SnapKit
import CoreData
import Alamofire
import SwiftSoup

class StretchyViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let timeTitle = UILabel()
    private let rubricTitle = UILabel()
    private let imageView = UIImageView()
    private let imageViewCover = UIImageView()
    private let textContainer = UIView()
    private let separatorContainer = UIImageView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
    private let news: News
    var bodies: [Body]!
    var styles: [String: [NSAttributedString.Key : Any]]!
    
    
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
        let mainFont = UIFont(name: "IBMPlexSerif", size: CGFloat(integerLiteral: 17)) ?? UIFont.systemFont(ofSize: CGFloat(integerLiteral: 17), weight: UIFont.Weight.regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = mainFont.lineHeight * 1.25
        //paragraphStyle.firstLineHeadIndent = 20
        //paragraphStyle.lineSpacing = 17
        /*
        family: IBM Plex Serif Thin
        name: IBMPlexSerif-ThinItalic
        name: IBMPlexSerif-Thin
        name: PingFangTC-Semibold
        name: AppleSDGothicNeo-SemiBold
        family: IBM Plex Serif Light
        name: IBMPlexSerif-LightItalic
        name: IBMPlexSerif-Light
        family: IBM Plex Serif
        name: IBMPlexSerif-Italic
        name: IBMPlexSerif-BoldItalic
        name: IBMPlexSerif-Bold
        name: IBMPlexSerif
         */
        styles = [
            "p" : [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: mainFont
            ],
            "p_i" : [
                NSAttributedString.Key.font: UIFont(name: "IBMPlexSerif-Italic", size: CGFloat(integerLiteral: 17)) ?? UIFont.systemFont(ofSize: CGFloat(integerLiteral: 17), weight: UIFont.Weight.regular)
            ],
            "p_b" : [
                NSAttributedString.Key.font: UIFont(name: "IBMPlexSerif-Bold", size: CGFloat(integerLiteral: 17)) ?? UIFont.systemFont(ofSize: CGFloat(integerLiteral: 17), weight: UIFont.Weight.regular)
            ],
            "question" : [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "IBMPlexSerif-BoldItalic", size: CGFloat(integerLiteral: 17)) ?? UIFont.systemFont(ofSize: CGFloat(integerLiteral: 17), weight: UIFont.Weight.regular)
            ],
            "link" : [
                NSAttributedString.Key.foregroundColor: UIColor.secondColor,
                NSAttributedString.Key.underlineColor: UIColor.secondColor,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ],
            "h1" : [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "PTRootUI-Bold", size: CGFloat(integerLiteral: 22)) ?? UIFont.systemFont(ofSize: CGFloat(integerLiteral: 22), weight: UIFont.Weight.bold)
            ]
        ]

        loadContent(url: news.link!)
        viewConfiguration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 85, green: 85, blue: 85, alpha: 0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = .clear
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
        var caption: String? = ""
        var credits: String? = ""
        imageView.image = UIImage(named: "Header")
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if (news.images?.count)! > 0 {
            for item in (news.images)! {
                let image = item as! Image
                let url = image.url ?? ""
                caption = image.caption
                credits = image.credits
                if url != "" {
                    loadImage(url: url, place: imageView)
                    break
                }
            }
        }
        imageViewCover.image = UIImage(named: "ImageCover")
        imageViewCover.contentMode = .scaleAspectFill
        imageViewCover.clipsToBounds = true
        imageViewCover.alpha = 0.3

        // Photo caption configuration
        let caprionLabel = UILabel()
        caprionLabel.numberOfLines = 0
        let muttableText = NSMutableAttributedString()
        if caption != nil {
            let attributes1 =  [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: "IBMPlexSerif-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
            ]
            let muttableCaption = NSMutableAttributedString(string: caption!, attributes: attributes1)
            muttableText.append(muttableCaption)
        }

        if credits != nil {
            let attributes2 =  [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: "IBMPlexSerif", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
            ]
            let muttableCredits = NSMutableAttributedString(string: credits!, attributes: attributes2)
            muttableText.append(NSMutableAttributedString(string: "\n"))
            muttableText.append(muttableCredits)
        }
        caprionLabel.attributedText = muttableText


        // Time configuration
        timeTitle.textColor = UIColor.secondColor
        timeTitle.font = UIFont(name: "IBMPlexSerif", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        timeTitle.numberOfLines = 0
        timeTitle.text = CoreDataManager.instance.GetTimeLocalosated(modified: Double(news.modified))
        
        // Separator
        separatorContainer.image = UIImage(named: "Circle")
        separatorContainer.contentMode = .scaleAspectFit
        separatorContainer.clipsToBounds = true

        // Rubric configuration
        rubricTitle.textColor = .gray
        rubricTitle.font = UIFont(name: "IBMPlexSerif", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        rubricTitle.numberOfLines = 0
        let rubric: String = news.rubric ?? "Новое"
        rubricTitle.text = CoreDataManager.instance.GetRubricTitle(name: rubric)

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
        scrollView.addSubview(imageViewCover)
        scrollView.addSubview(caprionLabel)
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
        
        imageViewCover.snp.makeConstraints {
            make in
            make.left.right.equalTo(imageContainer)
            make.top.equalTo(view).priority(.high)
            make.height.greaterThanOrEqualTo(imageContainer.snp.height).priority(.required)
            make.bottom.equalTo(imageContainer.snp.bottom)
        }

        caprionLabel.snp.makeConstraints {
            make in
            make.left.equalTo(scrollView).offset(15)
            make.bottom.equalTo(imageContainer.snp.bottom).offset(-15)
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
        
        
        textBacking.snp.makeConstraints {
            make in
            
            make.left.right.equalTo(view)
            make.top.equalTo(textContainer)
            make.bottom.equalTo(view)
        }
        
        
    }
    
    func reloadContent(data: News) {
        let contentText = UITextView()
        contentText.textColor = .black
        contentText.isUserInteractionEnabled = true
        contentText.isEditable = false
        contentText.isScrollEnabled = false
        contentText.delaysContentTouches = false
        textContainer.addSubview(contentText)
        
        let mutableText = NSMutableAttributedString(string: data.title!, attributes: styles["h1"])
        mutableText.append(NSAttributedString(string: "\n\n"))
        
        contentText.snp.makeConstraints {
            make in
            make.width.equalTo(view).offset(-20)
            make.left.equalTo(textContainer).offset(10)
            make.right.equalTo(textContainer).offset(10)
            make.top.equalTo(timeTitle.snp.bottom).offset(0)
            make.bottom.equalTo(textContainer).offset(-10)
        }

        let bCount: Int = data.bodies?.count ?? 0
        if bCount != 0 {
            var bodies = data.bodies?.allObjects as! [Body]
            bodies = bodies.sorted(by: { $0.position < $1.position })
            
            for (index, body) in bodies.enumerated() {
                let type = body.type!
                let params = styles[type] ?? [:]
                var mutableBody = NSMutableAttributedString()
                
                // Parses
                mutableBody = parseItalicBoldContent(content: body.content ?? "")
                mutableBody = parseHrefContent(content: mutableBody.string, params: params)
                
                mutableText.append(mutableBody)
                if index < bodies.count-1 {
                    mutableText.append(NSAttributedString(string: "\n"))
            }
            }
        } else {
            let mutableRightcol = NSMutableAttributedString(string: data.rightcol!, attributes: styles["p"])
            mutableText.append(mutableRightcol)
        }
        contentText.linkTextAttributes = styles["link"]
        contentText.attributedText = mutableText
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
        
    func parseItalicBoldContent(content: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: content)
        let elementsI: Elements = try! SwiftSoup.parse(content).select("i")
        for element in elementsI.array() {
            guard let text: String = try? element.html() else { break }
            guard let outerHtml: String = try? element.outerHtml() else { break }
            let foundRange: NSRange = (attributedString.string as NSString).range(of: outerHtml, options: .literal)
            if foundRange.length > 0 {
                attributedString.addAttributes(styles["p_i"]!, range: foundRange)
                attributedString.mutableString.replaceOccurrences(of: outerHtml, with: text, options: [], range: foundRange)
            }
        }
        let elementsB: Elements = try! SwiftSoup.parse(content).select("b")
        for element in elementsB.array() {
            guard let text: String = try? element.html() else { break }
            guard let outerHtml: String = try? element.outerHtml() else { break }
            let foundRange: NSRange = (attributedString.string as NSString).range(of: outerHtml, options: .literal)
            if foundRange.length > 0 {
                attributedString.addAttributes(styles["p_b"]!, range: foundRange)
                attributedString.mutableString.replaceOccurrences(of: outerHtml, with: text, options: [], range: foundRange)
            }
        }
        return attributedString
    }
    
    func parseHrefContent(content: String, params: [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: content, attributes: params)
        guard let els: Elements = try? SwiftSoup.parse(content).select("a") else { return attributedString }
        for element in els.array() {
            guard let hrefLink: String = try? element.attr("href") else { break }
            guard let textLink: String = try? element.text() else { break }
            guard let outerHtml: String = try? element.outerHtml() else { break }
            let foundRange: NSRange = (attributedString.string as NSString).range(of: outerHtml, options: .literal)
            if foundRange.length > 0 {
                attributedString.addAttribute(NSAttributedString.Key.link, value: hrefLink, range: foundRange)
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
        let frame = timeTitle.convert(timeTitle.bounds, to: nil)
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        if frame.minY <= 80 {
            //UIView.animate(withDuration: 0.2, animations: {
                statusBarView.backgroundColor = .darkGray
                self.navigationController?.navigationBar.backgroundColor = .darkGray
            //})
        } else {
            //UIView.animate(withDuration: 0.2, animations: {
                statusBarView.backgroundColor = .clear
                self.navigationController?.navigationBar.backgroundColor = UIColor(red: 85, green: 85, blue: 85, alpha: 0)
            //})
        }
        // 305 -> 80  :  0.3 -> 1
        let alp = 1.249 - 0.003 * frame.minY
        self.imageViewCover.alpha = alp
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
