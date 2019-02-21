import UIKit
import Alamofire
import AlamofireObjectMapper
//import AudioToolbox


protocol TableViewDelegate: class {
    func scrollView(_ scrollView: UIScrollView)
    func selectRow(newsForRead: FeedResponse)
}

class TableViewController: UITableViewController {
    
    var delegate: TableViewDelegate?
    
    private static let CellIdentifier = "CellIdentifier"
    var newsFeed = [FeedResponse]()
    var refreshTableControl: UIRefreshControl!
    let cellTableIdentifier = "CellIdentifier"
    fileprivate let rubric: NewsRubric

    init(rubric: NewsRubric) {
        self.rubric = rubric
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewController.CellIdentifier)
        let cellXib = UINib(nibName: "NewsFeedCell", bundle: nil)
        tableView.register(cellXib, forCellReuseIdentifier: cellTableIdentifier)
        refreshTableControl = UIRefreshControl()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshTableControl
        } else {
            tableView.addSubview(refreshTableControl)
        }
        
        // Configure Refresh Control
        refreshTableControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        refreshTableControl.tintColor = UIColor.secondColor
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PTRootUI-Regular", size: 12)!,
            .foregroundColor: UIColor.secondColor]
        refreshTableControl.attributedTitle = NSAttributedString(string: "Обновление ленты", attributes: attributes)
        
        tableView.rowHeight = UITableView.automaticDimension

        

        let defaults = UserDefaults.standard
        let lastUpdate = defaults.object(forKey: rubric.name + "Update") as? Date ?? Date()
        let currentDate = Date()
        let differTime = (currentDate.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970)
            / 60  // mins
        
        if let outData = UserDefaults.standard.data(forKey: rubric.name) {
            newsFeed = NSKeyedUnarchiver.unarchiveObject(with: outData) as! [FeedResponse]
        }
        
        if differTime >= 15 || newsFeed.count == 0 {
            getLatestList()
        } else {
            tableView.reloadData()
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
        return newsFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier) as! NewsCellController
        let item = self.newsFeed[indexPath.row]
        cell.dateLabel.text = item.infoTime ?? "Сейчас"
        cell.rubricLabel.text = item.rubricTitle ?? "Новости"
        cell.titleLabel.text = item.infoTitle ?? "- без названия -"
        cell.descrLabel.text = item.infoRightcol ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //delegate?.selectRow(newsForRead: newsFeed[indexPath.row])
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newsView") as! ReadViewController
        newsVC.newsFeed = newsFeed[indexPath.row]
        self.navigationController?.pushViewController(newsVC, animated: true)

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
                
                let defaults = UserDefaults.standard
                defaults.set(Date(), forKey: self.rubric.name + "Update")
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.newsFeed)
                defaults.set(encodedData, forKey: self.rubric.name)
                defaults.synchronize()
                
                self.tableView.reloadData()
                self.refreshTableControl.endRefreshing()
                //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
        }
    }

    
}
