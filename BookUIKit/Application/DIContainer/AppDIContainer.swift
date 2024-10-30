//
//  AppDIContainer.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseUrl)!,
                                          queryParameters: [
                                            "api_key" : appConfiguration.apiKey,
                                            "language" : NSLocale.preferredLanguages.first ?? "en"
                                          ]
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiImageBaseUrl)!)
        let imageDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: imageDataNetwork)
    }()
    
    // MARK: - DIContainers of scenes
    
    func makeMoviesSceneDIContainer() -> MoviesSceneDIContainer {
        let dependencies = MoviesSceneDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService,
            imageDataTransferService: imageDataTransferService
        )
        return MoviesSceneDIContainer(dependencies: dependencies)
    }
    
}
