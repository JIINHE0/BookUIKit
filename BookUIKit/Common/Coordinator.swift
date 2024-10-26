//
//  Coordinator.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import UIKit

enum CoordinatorType {
    case home, search, list
    case tab
}

protocol CoordinatorFinishDelegate {
    var coordinatorDidFinish: (_ shildCoordinator: Coordinator) -> Void { get set }
}

protocol Coordinator: AnyObject {
    // 부모 코디네이터가 자식이 finish 됐을 때 알 수 있도록 돕는 delegate 프로토콜 (finish 될 일이 없음, 로그인 제외)
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    
    // 각각의 코디네이터는 하나의 네비게이션 컨트롤러를 가지고 있음
    var navigationController: UINavigationController { get set }
    
    // 모든 하위 코디네이터를 가지고 추적하는 배열, 대부분 이 배열에는 하위 코디네이터가 하나만 포함
    var childCoordinators: [Coordinator] { get set }
    
    var type: CoordinatorType { get }
    
    
    init (navigationController: UINavigationController)
    
    func start()
    func finish()
    
//    func findCoordinator(type: Coordinator) -> Coordinator?
}

// 프로토콜 구현 
extension Coordinator {
    
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(self)
    }
    
//    func findCoordinator(type: CoordinatorType) -> Coordinator? {
//        var stack: [Coordinator] = [self]
//        
//        while !stack.isEmpty {
//            let currentCoordinator = stack.removeLast()
//            if currentCoordinator.type == type {
//                return currentCoordinator
//            }
//            
//            currentCoordinator.childCoordinators.forEach { stack.append($0) }
//        }
//        
//        return nil
//    }
}
