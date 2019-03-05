import UIKit
import Alamofire
import AlamofireObjectMapper
import CoreData


protocol TableViewDelegate: class {
    func scrollView(_ scrollView: UIScrollView)
}

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let rubric: NewsRubric
    let cellTableIdentifier = "CellIdentifier"
    var delegate: TableViewDelegate!
    var newsFeed = [FeedResponse]()
    var refreshTableControl: UIRefreshControl!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
        
    init(rubric: NewsRubric) {
        self.rubric = rubric
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellXib = UINib(nibName: "NewsFeedCell", bundle: nil)
        tableView.register(cellXib, forCellReuseIdentifier: cellTableIdentifier)
        tableView.rowHeight = UITableView.automaticDimension

        // Configure Refresh Control
        refreshTableControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshTableControl
        } else {
            tableView.addSubview(refreshTableControl)
        }
        refreshTableControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        refreshTableControl.tintColor = UIColor.secondColor
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PTRootUI-Regular", size: 12)!,
            .foregroundColor: UIColor.secondColor]
        refreshTableControl.attributedTitle = NSAttributedString(string: "Обновление ленты", attributes: attributes)
        
        fetchedResultsController = GetFetchedResultController(rubricName: rubric.name)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        let lastUpdate = defaults.object(forKey: rubric.name + "Update") as? Date ?? Date()
        let currentDate = Date()
        let differTime = (currentDate.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970)
            / 60  // mins
        
        let countNews = fetchedResultsController.fetchedObjects?.count ?? 0
        if differTime >= 5 /* mins */ || countNews == 0 {
            getLatestList()
        } else {
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print(error)
            }
            print("cache")
        }
    }
    
    @objc private func refreshNewsData(_ sender: Any) {
        // Fetch Weather Data
        getLatestList()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier) as! NewsCellController
        let item = fetchedResultsController.object(at: indexPath) as! News
        configCell(cell: cell, item: item)
        return cell
    }
    
    func configCell(cell: NewsCellController, item: News) {
        let rubric: String = item.rubric ?? "Новое"
        cell.dateLabel.text = CoreDataManager.instance.GetTimeLocalosated(modified: Double(item.modified))
        cell.rubricLabel.text = CoreDataManager.instance.GetRubricTitle(name: rubric)
        cell.titleLabel.text = item.title
        cell.descrLabel.text = item.rightcol
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = fetchedResultsController.fetchedObjects?[indexPath.row] as? News
        let lentaVC = StretchyViewController(news: news!)
        self.navigationController?.pushViewController(lentaVC, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollView(scrollView)
    }
   
    func getLatestList() -> Void {
        print("new data")
        let headers: HTTPHeaders = [
            "User-Agent": "Lenta/1.4.2 (iPhone; iOS 10.3.2; Scale/2.00)",
            "X-Lenta-Media-Type": "1",
            "Accept-Language": "ru-RU;q=1, en-RU;q=0.9",
            "Accept": "application/json"
        ]
        
        Alamofire.request("https://api.lenta.ru/" + self.rubric.url, method: .get, headers: headers)
            .downloadProgress { progress in
                //self.progressBar.progress = Float(progress.fractionCompleted)
            }
            .responseArray(keyPath: "headlines") { (response: DataResponse<[FeedResponse]>) in
                self.newsFeed = response.result.value ?? [FeedResponse]()
                
                // Update Last touch to news
                let defaults = UserDefaults.standard
                defaults.set(Date(), forKey: self.rubric.name + "Update")
                defaults.synchronize()

                for item in self.newsFeed {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
                    fetchRequest.predicate = NSPredicate(format: "id = %@", item.infoId!)
                    do {
                        let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [News]
                        if results?.count == 0 {
                            let news = News()
                            news.id = item.infoId
                            news.title = item.infoTitle
                            news.link = item.linksSelf
                            news.modified = Int32(item.infoModified!)
                            news.readed = 0
                            news.favotite = false
                            news.announce = ""
                            news.rightcol = item.infoRightcol
                            news.rubric = item.rubricSlug
                            news.type = item.type
                            if self.rubric.name == "latest" {
                                news.latest = true
                            }
                            if self.rubric.name == "popular" {
                                news.popular = true
                            }
                            
                            let image = Image()
                            image.caption = item.imageCaption
                            image.credits = item.imageCredits
                            image.position = 0
                            image.url = item.imageUrl
                            image.news = news
                        } else {
                            if self.rubric.name == "latest" {
                                results?[0].latest = true
                            }
                            if self.rubric.name == "popular" {
                                results?[0].popular = true
                            }
                        }
                    } catch {
                        print("Fetch Failed: \(error)")
                    }
                    CoreDataManager.instance.saveContext()
                }
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    print(error)
                }
                self.tableView.reloadData()
                self.refreshTableControl.endRefreshing()
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
        }
    }
    
    func GetFetchedResultController(rubricName: String) -> NSFetchedResultsController<NSFetchRequestResult>  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        if rubricName == "latest" {
            fetchRequest.predicate = NSPredicate(format: "latest = true")
        } else if rubricName == "popular" {
            fetchRequest.predicate = NSPredicate(format: "popular = true")
        } else {
            fetchRequest.predicate = NSPredicate(format: "rubric = %@", rubricName)
        }
        let sortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 100
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    
}
