//
//  AppConfiguration.swift
//  BookUIKit
//
//  Created by jiin heo on 10/26/24.
//

import Foundation

final class AppConfiguration {
    
//    lazy var apikey: String = {
        
        // 전체 딕셔너리에서 키를 가져오므로 코드가 간결
        // 주의점: infoDictionary는 iOS 16 이상에서 null을 반환하는 경우가 있기 때문에, 레거시 지원이 필요한 경우 사용할 때 유의
//        guard let apiKey = Bundle.main.infoDictionary?["ApiKey"] as? String else {
//            fatalError("ApiKey mus not be empty in plist")
//        }
        
        // 특정 키로 개별값만 가져오기 때문에 런타임 비용이 적고, iOS 버전과 관계 없이 작동
        let apiKey = "2696829a81b1b5827d515ff121700838"
//        guard let apiKey = "2696829a81b1b5827d515ff121700838"
//                Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
//            fatalError("ApiKey mus not be empty in plist")
//        }
//        return apiKey
//    }()
    
        
        var apiBaseUrl = "http://api.themoviedb.org/"
        var apiImageBaseUrl = "http://image.tmdb.org/"
        
        
//    lazy var apiBaseUrl: String = {
//            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
//            fatalError("APIBaseUrl mus not be empty in plist")
//        }
//        return apiBaseUrl
//    }()
//    
//    lazy var apiImageBaseUrl: String = {
//            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as? String else {
//            fatalError("APIImageBaseUrl mus not be empty in plist")
//        }
//        return apiImageBaseUrl
//    }()
}
