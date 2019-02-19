//
//  NewsViewController.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/1/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import UIKit
import Parchment


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

struct NewsRubric {
    let name: String
    let title: String
    let url: String
    let selected: Bool
}

class NewsViewController: UIViewController, TableViewDelegate {
    private let items = [
        NewsRubric(name: "latest", title: "Новое", url: "lists/latest", selected: true),
        NewsRubric(name: "popular", title: "Популярное", url: "lists/popular", selected: true),
        NewsRubric(name: "russia", title: "Россия", url: "rubrics/russia", selected: true)
    ]
    
    private let pagingViewController = CustomPagingViewController()
    private var selectedItemIndex = 0
    private var barStatus = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //listOfFonts()
        removeNavBarBorder()
        
        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)

        // Customize the menu styling.
        pagingViewController.textColor = .black
        pagingViewController.font = UIFont(name: "PTRootUI-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        pagingViewController.selectedFont = UIFont(name: "PTRootUI-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        pagingViewController.selectedTextColor = UIColor.secondColor
        pagingViewController.indicatorColor = UIColor.secondColor
        pagingViewController.indicatorOptions = .visible(
            height: 1,
            zIndex: Int.max,
            spacing: .zero,
            insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        )
        //pagingViewController.menuItemSize = .sizeToFit(minWidth: 50, height: 30)
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.menuInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        // Set our data source and delegate.
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
    }
    
    /// Calculate the menu offset based on the content offset of the
    /// scroll view.
    private func menuOffset(for scrollView: UIScrollView) -> CGFloat {
        return min(pagingViewController.options.menuHeight, max(0, scrollView.contentOffset.y))
    }
    
    func removeNavBarBorder() -> Void {
        if barStatus != 0 {
            let upperTitle = NSMutableAttributedString(string: "LENTA", attributes: [NSAttributedString.Key.font: UIFont(name: "MinionPro-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black])
            let upperTitlePlus = NSMutableAttributedString(string: "+", attributes: [NSAttributedString.Key.font: UIFont(name: "MinionPro-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.secondColor])
            upperTitle.append(upperTitlePlus)
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height:44))
            label1.numberOfLines = 0
            label1.textAlignment = .center
            label1.attributedText = upperTitle
            let duration = (barStatus == -1) ? 0 : 0.5
            
            UIView.animate(withDuration: duration) {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.barStyle = .default
                self.navigationController?.navigationBar.layoutIfNeeded()
                self.navigationItem.titleView = label1
            }
            barStatus = 0
        }
    }
    
    func restoreNavBarBorder() -> Void {
        if barStatus != 1 {
            let upperTitle = NSMutableAttributedString(string: "LENTA", attributes: [NSAttributedString.Key.font: UIFont(name: "MinionPro-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white])
            let upperTitlePlus = NSMutableAttributedString(string: "+", attributes: [NSAttributedString.Key.font: UIFont(name: "MinionPro-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.secondColor])
            let lowerTitle = NSMutableAttributedString(string: "\n\(items[selectedItemIndex].title)", attributes: [NSAttributedString.Key.font: UIFont(name: "PTRootUI-Light", size: 12)! , NSAttributedString.Key.foregroundColor: UIColor(hue: 0, saturation: 0, brightness: 91, alpha: 1)])
            upperTitle.append(upperTitlePlus)
            upperTitle.append(lowerTitle)
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height:44))
            label1.numberOfLines = 0
            label1.textAlignment = .center
            label1.attributedText = upperTitle
            
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
                self.navigationController?.navigationBar.shadowImage = nil
                self.navigationController?.navigationBar.layoutIfNeeded()
                self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
                self.navigationController?.navigationBar.barStyle = .black
                self.navigationItem.titleView = label1
            }
            barStatus = 1
        }
    }
    
    
    func listOfFonts() -> Void {
        for family in UIFont.familyNames {
            
            let sName: String = family as String
            print("family: \(sName)")
            
            for name in UIFont.fontNames(forFamilyName: sName) {
                print("name: \(name as String)")
            }
        }
    }

    func scrollView(_ scrollView: UIScrollView) {
        // Offset the menu view based on the content offset of the scroll view.
        
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
    
    func selectRow(indexPath: IndexPath) {
    }
    
}

extension NewsViewController: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        let viewController = TableViewController(rubric: items[index])
        
        // Inset the table view with the height of the menu height.
        let menuHeight = pagingViewController.options.menuHeight
        let insets = UIEdgeInsets(top: menuHeight, left: 0, bottom: 0, right: 0)
        viewController.tableView.contentInset = insets
        viewController.tableView.scrollIndicatorInsets = insets
        
        // Set delegate so that we can listen to scroll events.
        //viewController.tableView.delegate = self
        
        // Set custom delegate
        viewController.delegate = self
        
        return viewController
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: items[index].title) as! T
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int{
        return items.count
    }
    
}

extension NewsViewController: PagingViewControllerDelegate {
    
    // We want to transition the menu offset smoothly to it correct
    // position when we are swiping between pages.
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, isScrollingFromItem currentPagingItem: T, toItem upcomingPagingItem: T?, startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? TableViewController else { return }
        guard let startingViewController = startingViewController as? TableViewController else { return }
        guard let menuView = pagingViewController.view as? CustomPagingView else { return }
        
        // Tween between the current menu offset and the menu offset of
        // the destination view controller.
        let from = menuOffset(for: startingViewController.tableView)
        let to = menuOffset(for: destinationViewController.tableView)
        let offset = ((to - from) * abs(progress)) + from
        
        
        menuView.menuTopConstraint?.constant = -offset
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        selectedItemIndex = pagingViewController.visibleItems.indexPath(for: pagingItem)?.row ?? 0
    }
}

