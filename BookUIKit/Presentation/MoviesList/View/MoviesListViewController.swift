//
//  MoviesListViewController.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import Foundation
import UIKit

final class MoviesListViewController: UIViewController, Alertable, UICollectionViewDataSource {

    
    private lazy var suggestionsListContainer: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 44)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionView.self, forCellWithReuseIdentifier: "TextCell")
        collectionView.dataSource = self
        view.addSubview(collectionView)
        return collectionView
    }()
    
    private var moviesListContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()

    private var searchBarContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private var emptyDataLable: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var viewModel: MoviesListViewModel!
    private var posterImageRepository: PosterImagesRepository?
    
    private var moviesTableViewController: MoviesListViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: MoviesListViewModel, posterImagesRepository: PosterImagesRepository?) -> MoviesListViewController {
        let view = MoviesListViewController()
        view.viewModel = viewModel
        view.posterImageRepository = posterImagesRepository
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Movies"
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor.white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        [moviesListContainer, emptyDataLable, suggestionsListContainer, searchBarContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            moviesListContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            moviesListContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            moviesListContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            moviesListContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    
        NSLayoutConstraint.activate([
            suggestionsListContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            suggestionsListContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            suggestionsListContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            suggestionsListContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            emptyDataLable.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyDataLable.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        
        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
    private func bind(to viewModel: MoviesListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue
    }
    
    // MARK: - Private
    
    private func setupViews() {
        self.view.backgroundColor = .white
        self.emptyDataLable.text = viewModel.emptyDataTitle
        setupSearchController()
    }
    
    private func updateItems() {
        // TODO: - 아직 구현 안함 - MoviesListTableViewController
//        moviewListContainer.reload
    }
    
    private func updateLoading(_ loading: MoviesListViewModelLoading?) {
        emptyDataLable.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        LoadingView.hide()
        
        switch loading {
        case .fullScreen: LoadingView.show()
        case .nextPage: moviesListContainer.isHidden = false
        case .none:
            moviesListContainer.isHidden = viewModel.isEmpty
            emptyDataLable.isHidden = !viewModel.isEmpty
        }
        
        moviesTableViewController?.updateLoading(loading)
        updateQueriesSuggestions()
    }
    
    private func updateQueriesSuggestions() {
        guard searchController.searchBar.isFirstResponder else {
            viewModel.closeQueriesSuggestions()
            return
        }
        viewModel.showQueriesSuggestions()
    }
    
    private func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else {return}
        showAlert(title: viewModel.errorTitle, message: error)
    }
    
}

// MARK: - Search Controller
extension MoviesListViewController {
    private func setupSearchController() {
        self.navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        viewModel.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
    }
}

extension MoviesListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
}


struct AccessibilityIdentifier {
    static let movieDetailsView = "AccessibilityIdentifierMovieDetailsView"
    static let searchField = "AccessibilityIdentifierSearchMovies"
}
