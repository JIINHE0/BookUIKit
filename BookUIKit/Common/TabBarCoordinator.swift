//
//  TabBarCoordinator.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import UIKit

protocol TabBarCoordinator: Coordinator {
    var tabBarController: UITabBarController { get set }
}

final class DefaultTabBarCoordinator: Coordinator, HomeCoordinatorDelegate {
    
    var finishDelegate: (any CoordinatorFinishDelegate)?
    
    
    func showPersonalChat() {
        print("Test")
    }
    

    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .home
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // 홈 코디네이터 시작
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.homeDelegate = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
    
    // MARK: - HomeCoordinatorDelegate
    func didFinishHomeFlow() {
        print("Home flow finished.")
    }
    
    // MARK: - LoginCheckDelegate
    func checkLoginStatus() {
        print("Checking login status.")
    }
    
    // MARK: - CoordinatorFinishDelegate
    func coordinatorDidFinish(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}
