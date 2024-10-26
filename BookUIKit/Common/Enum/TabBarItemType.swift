//
//  TabBarItemType.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import Foundation

enum TabBarItemType: String, CaseIterable {
    case home, search, list
    
    init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .search
        case 2: self = .list
        default: return nil
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .home: return 0
        case .search: return 1
        case .list: return 2
        }
    }
    
    func toName() -> String {
        switch self {
        case .home: return "홈"
        case .search: return "서치"
        case .list: return "리스트"
        }
    }
    
    func toIconNamte() -> String {
        switch self {
        case .home: return "house"
        case .search: return "search"
        case .list: return "list"
        }
    }
}
