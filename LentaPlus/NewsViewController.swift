//
//  NewsViewController.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/1/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import UIKit
import Parchment
import CoreData
import SnapKit

struct NewsRubric {
    let name: String
    let title: String
    let url: String
    let selected: Bool
}

class NavItemTitle {
    static let instance = NavItemTitle()
    
    var titleRubric: String = ""
    
    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 25))
    let imageView = UIImageView(image: UIImage(named: "logo-white"))
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height:15))

    private init() {}
    
    func setRubricTitle(titleRubric:String) -> Void {
        self.titleRubric = titleRubric
        label.text = titleRubric
    }
    
    func getNavTitle(titleRubric:String, width: CGFloat, height: CGFloat) -> UIView {
        self.titleRubric = titleRubric
        let bannerX = width / 2 - 110 / 2
        let bannerY = height / 2 - 23 / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: 110, height: 44)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.origin.x = (300 - 100 ) / 2
        imageView.frame.origin.y = 0
        titleView.addSubview(imageView)
        
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "PTRootUI-Light", size: 12)!
        label.textColor = UIColor(hue: 0, saturation: 0, brightness: 91, alpha: 1)
        label.text = titleRubric
        label.frame.origin.y = 45
        label.alpha = 0
        titleView.addSubview(label)
        
        return titleView
    }
    
    func showNavSubtitle() -> Void {
        UIView.animate(withDuration: 0.5) {
            self.imageView.frame.origin.y = -15
            self.label.frame.origin.y = 15
            self.label.alpha = 1
        }
    }

    func hideNavSubtitle() -> Void {
        UIView.animate(withDuration: 0.5) {
            self.imageView.frame.origin.y = 0
            self.label.frame.origin.y = 45
            self.label.alpha = 0
        }
    }
    
    func getView() -> UIView {
        return titleView
    }

}

class CustomPagingView: PagingView {
    
    var menuTopConstraint: NSLayoutConstraint?
    
    override func setupConstraints() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        menuTopConstraint = collectionView.topAnchor.constraint(equalTo: topAnchor)
        menuTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: options.menuHeight),
            
            pageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageView.topAnchor.constraint(equalTo: topAnchor)
            ])
    }
}

// Create a custom paging view controller and override the view with
// our own custom subclass.
class CustomPagingViewController: PagingViewController<PagingIndexItem> {
    
    override func loadView() {
        view = CustomPagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view
        )
        collectionView.backgroundColor = .clear
    }
}

class NewsViewController: UIViewController, TableViewDelegate {
    private var items = [NewsRubric]()
    private let pagingViewController = CustomPagingViewController()
    private var selectedItemIndex = 0
    private var needBarUpdateStatus = -1
    private var pageControllers: [TableViewController] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get fonts names
        //listOfFonts()
        
        // Show path to SQLite local storage
        //let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        //print(paths[0])
        

        items = getRubrics()
        
        // Add the paging view controller as a child view controller and contrain it to all edges.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        
        // Customize the menu styling.
        pagingViewController.menuBackgroundColor = UIColor.darkGray
        pagingViewController.backgroundColor = UIColor.darkGray
        pagingViewController.textColor = UIColor.lightGray
        let ptFont = UIFont(name: "PTRootUI-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        pagingViewController.font = ptFont
        pagingViewController.selectedFont = ptFont
        pagingViewController.selectedBackgroundColor = UIColor.darkGray
        pagingViewController.borderColor = UIColor.darkGray
        pagingViewController.selectedTextColor = UIColor.white
        pagingViewController.indicatorColor = UIColor.secondColor
        pagingViewController.indicatorOptions = .visible(
            height: 2,
            zIndex: Int.max,
            spacing: .zero,
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        )
        pagingViewController.borderOptions = .visible(
            height: 2,
            zIndex: Int.max - 1,
            insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.selectedScrollPosition = .preferCentered
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 50, height: 40)
        pagingViewController.menuItemSpacing = 0
        pagingViewController.menuInteraction = .swipe
        pagingViewController.includeSafeAreaInsets = false
        
        // Set our data source and delegate.
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray
        if needBarUpdateStatus == -1 {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
            self.navigationController?.navigationBar.barStyle = .black

            let bannerWidth = self.navigationController?.navigationBar.frame.size.width ?? 0
            let bannerHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
            self.navigationItem.titleView = NavItemTitle.instance.getNavTitle(titleRubric: items[selectedItemIndex].title, width: bannerWidth, height: bannerHeight)
        }
        needBarUpdateStatus = 0
    }
    
    // Calculate the menu offset based on the content offset of the scroll view.
    private func menuOffset(for scrollView: UIScrollView) -> CGFloat {
        return min(pagingViewController.options.menuHeight, max(0, scrollView.contentOffset.y))
    }
    
    // Modify NavBar: remove bottom border, create colored title
    func removeNavBarBorder() -> Void {
        if needBarUpdateStatus != 0 {
            NavItemTitle.instance.hideNavSubtitle()
            needBarUpdateStatus = 0
        }
    }
    
    // Modify NavBar: change back and title
    func restoreNavBarBorder() -> Void {
        if needBarUpdateStatus != 1 {
            NavItemTitle.instance.showNavSubtitle()
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            NavItemTitle.instance.getView().addGestureRecognizer(tap)
            NavItemTitle.instance.getView().isUserInteractionEnabled = true
            needBarUpdateStatus = 1
       }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        //print(openedController.rubric.name)
        let indexPath = IndexPath(row: 0, section: 0)
        let viewController = pageControllers[selectedItemIndex]
        viewController.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // Show list all Fonts
    func listOfFonts() -> Void {
        for family in UIFont.familyNames {
            
            let sName: String = family as String
            print("family: \(sName)")
            
            for name in UIFont.fontNames(forFamilyName: sName) {
                print("name: \(name as String)")
            }
        }
    }

    // Offset the menu view based on the content offset of the scroll view.
    func scrollView(_ scrollView: UIScrollView) {
        if let menuView = pagingViewController.view as? CustomPagingView {
            let offset = menuOffset(for: scrollView)
            menuView.menuTopConstraint?.constant = -offset
            if offset >= pagingViewController.options.menuHeight {
                restoreNavBarBorder()
            } else {
                removeNavBarBorder()
            }
        }
    }
    
    // Get customed Lenta's Rubrics or create those entity as default
    func getRubrics() -> [NewsRubric] {
        // default definition rubrics
        var retItems = [
            NewsRubric(name: "latest", title: "Новое", url: "lists/latest", selected: true),
            NewsRubric(name: "popular", title: "Популярное", url: "lists/popular", selected: true),
            NewsRubric(name: "russia", title: "Россия", url: "rubrics/russia", selected: true),
            NewsRubric(name: "world", title: "Мир", url: "rubrics/world", selected: false),
            NewsRubric(name: "ussr", title: "Бывший СССР", url: "rubrics/ussr", selected: false),
            NewsRubric(name: "economics", title: "Экономика", url: "rubrics/economics", selected: false),
            NewsRubric(name: "forces", title: "Силовые структуры", url: "rubrics/forces", selected: false),
            NewsRubric(name: "science", title: "Наука и техника", url: "rubrics/science", selected: false),
            NewsRubric(name: "sport", title: "Спорт", url: "rubrics/sport", selected: false),
            NewsRubric(name: "culture", title: "Культура", url: "rubrics/culture", selected: false),
            NewsRubric(name: "media", title: "Интернет и СМИ", url: "rubrics/media", selected: false),
            NewsRubric(name: "style", title: "Ценности", url: "rubrics/style", selected: false),
            NewsRubric(name: "travel", title: "Путешествия", url: "rubrics/travel", selected: false),
            NewsRubric(name: "life", title: "Из жизни", url: "rubrics/life", selected: false),
            NewsRubric(name: "realty", title: "Дом", url: "rubrics/realty", selected: false)
        ]
        // Create Fetch to get Rubrics
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rubric")
        fetchRequest.predicate = NSPredicate(format: "favorite = true")
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 5
        do {
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count == 0 {
                // Create default rubrics
                var i = 0
                var retItemsSelected = [NewsRubric]()
                for item in retItems {
                    let rubric = Rubric()
                    rubric.id = item.name
                    rubric.title = item.title
                    rubric.link = item.url
                    rubric.slug = ""
                    rubric.position = Int16(i)
                    rubric.favorite = item.selected
                    i += 1
                    if item.selected == true {
                        retItemsSelected.append(item)
                    }
                }
                retItems = retItemsSelected
                CoreDataManager.instance.saveContext()
            } else {
                // Get data from CD
                retItems.removeAll()
                for item in results as! [Rubric]  {
                    if item.favorite {
                        retItems.append(
                            NewsRubric( name: item.id!,
                                        title: item.title!,
                                        url: item.link!,
                                        selected: item.selected
                            )
                        )
                    }
                }
            }
            
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        // Create stack of controllers
        pageControllers.removeAll()
        for i in 0..<retItems.count {
            let viewController = TableViewController(rubric: retItems[i])
            pageControllers.append(viewController)
            // Inset the table view with the height of the menu height.
            let menuHeight = pagingViewController.options.menuHeight
            let insets = UIEdgeInsets(top: menuHeight, left: 0, bottom: 0, right: 0)
            viewController.tableView.contentInset = insets
            viewController.tableView.scrollIndicatorInsets = insets
            
            // Set delegate so that we can listen to scroll events.
            //viewController.tableView.delegate = self
            // Set custom delegate
            viewController.delegate = self
        }
        
        return retItems
    }
}
    

extension NewsViewController: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return pageControllers[index]
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: items[index].title) as! T
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int{
        return items.count
    }
    
}

extension NewsViewController: PagingViewControllerDelegate {
    
    // We want to transition the menu offset smoothly to it correct position when we are swiping between pages.
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, isScrollingFromItem currentPagingItem: T, toItem upcomingPagingItem: T?, startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? TableViewController else { return }
        guard let startingViewController = startingViewController as? TableViewController else { return }
        guard let menuView = pagingViewController.view as? CustomPagingView else { return }
        
        // Tween between the current menu offset and the menu offset of the destination view controller.
        let from = menuOffset(for: startingViewController.tableView)
        let to = menuOffset(for: destinationViewController.tableView)
        let offset = ((to - from) * abs(progress)) + from
        menuView.menuTopConstraint?.constant = -offset
        if offset > 0 && self.needBarUpdateStatus == 1 {
            removeNavBarBorder()
        }
        if offset >= 40 && self.needBarUpdateStatus == 0 {
            restoreNavBarBorder()
        }
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        selectedItemIndex = pagingViewController.visibleItems.indexPath(for: pagingItem)?.row ?? 0
        NavItemTitle.instance.setRubricTitle(titleRubric: items[selectedItemIndex].title)
    }
}


