//
//  MoviesSearchFlowCoordinator.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import UIKit

protocol MoviesSearchFlowCoordinatorDependencies {
    func makeMoviesListViewController (action: MoviesListViewModelActions) -> MoviesListViewController
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController
//    func makeMoviesQueriesSeuggestionsListViewController(didSelect: @escaping MoviesQuer)
}

final class MoviesSearchFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: MoviesSearchFlowCoordinatorDependencies

    private weak var moviesListVC: MoviesListViewController?
    private weak var moviesQueriesSuggestionsVC: UIViewController?
    
    init(
        navigationController: UINavigationController? = nil,
        dependencies: MoviesSearchFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = MoviesListViewModelActions(showMovieDetails: showMovieDetails,
            showMovieQueriesSuggestions: showMovieQueriesSuggestions,
            closeMovieQueriesSuggestions: closeMovieQueriesSuggestions
        )
        
        let vc = dependencies.makeMoviesListViewController(action: actions)

        navigationController?.pushViewController(vc, animated: false)
        moviesListVC = vc
    }

    private func showMovieDetails(movie: Movie) {
        let vc = dependencies.makeMoviesDetailsViewController(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showMovieQueriesSuggestions(didSelect: @escaping (MovieQuery) -> Void) {
//        guard let moviesListViewController = moviesListVC, moviesQueriesSuggestionsVC == nil,
//            let container = moviesListViewController.suggestionsListContainer else { return }
//
//        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(didSelect: didSelect)
//
//        moviesListViewController.add(child: vc, container: container)
//        moviesQueriesSuggestionsVC = vc
//        container.isHidden = false
    }
    
    private func closeMovieQueriesSuggestions() {
//        moviesQueriesSuggestionsVC?.remove()
//        moviesQueriesSuggestionsVC = nil
//        moviesListVC?.suggestionsListContainer.isHidden = true
    }
}

