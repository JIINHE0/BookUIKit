//
//  TabbarVC.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import UIKit

class TabbarVC: UITabBarController {
    
    private lazy var todayViewController: UIViewController = {
        let viewController = HomeVC()
        let tabbarItem = UITabBarItem(title: "투데이", image: UIImage(systemName: "doc.text.image"), tag: 0)
        viewController.tabBarItem = tabbarItem
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = HomeVC()
        let searchVC = SearchVC()
        let listVC = ListVC()
        
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "doc.text.image"), tag: 0)
        searchVC.tabBarItem = UITabBarItem(title: "search", image: UIImage(systemName: "doc.text.image"), tag: 1)
        listVC.tabBarItem = UITabBarItem(title: "list", image: UIImage(systemName: "doc.text.image"), tag: 2)
        
        viewControllers = [homeVC, searchVC, listVC]
        
    }
}

