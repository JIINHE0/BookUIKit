//
//  HomeCoordinator.swift
//  BookUIKit
//
//  Created by jiin heo on 10/21/24.
//

import Foundation
import UIKit

// 코디네이터 : 코디네이터 관계일 때 사용
protocol HomeCoordinatorDelegate: AnyObject {
    func showPersonalChat( )
}

// 홈에 관련된 코디네이터 프로토콜
protocol HomeCoordinatorProtocol: Coordinator {
    
    var homeViewController: HomeVC { get set }
    
    // Home에서 필요한 화면
    func pushSearhviewControlelr()
    func showDetailController()
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    
    weak var homeDelegate: HomeCoordinatorDelegate?
    
    var homeViewController: HomeVC
    
    var navigationController: UINavigationController

    var finishDelegate: (any CoordinatorFinishDelegate)?
    
    var childCoordinators: [any Coordinator]
    
    var type: CoordinatorType
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController // 필수
        self.homeViewController = HomeVC() // 기본적으로 홈 화면 뷰 컨트롤러 생성
        self.finishDelegate = nil  // 기본적으로 nil로 설정, 이후에 필요 시 세팅
        self.childCoordinators = [] // 초기화 시 자식 코디네이터는 없으므로 빈 배열
        self.type = .home  // 이 코디네이터의 역할을 홈 화면 담당으로 설정
    }
    
    func start() {
        print("test start findCoordinator")
        
        homeViewController.didSendEventClosure = { [weak self] (event: Event) in
            switch event {
            case .showSearch:
                self?.pushSearhviewControlelr()
            case .showProjectWrite:
                self?.showDetailController()
            case .showLogin:
                self?.showDetailController()
            }
        }
    }
    
    func findCoordinator(type: any Coordinator) -> (any Coordinator)? {
        return nil
    }
    
    // MARK: - 홍에서 동작
    func pushSearhviewControlelr() {
        print("test findCoordinator")
    }
    
    func showDetailController() {
        print("test findCoordinator")
    }
    
}
