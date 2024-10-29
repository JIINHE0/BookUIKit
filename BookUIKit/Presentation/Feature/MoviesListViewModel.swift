//
//  MoviesListViewModel.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import Foundation

/// 사용자가 수행할 액션을 정의하는 구조체
/// - showMovieDetails: 영화 상세 화면을 보여주는 액션
/// - showMovieQueriesSuggestions: 영화 검색어 제안 목록을 보여주는 액션
/// - closeMovieQueriesSuggestions: 검색어 제안 목록을 닫는 액션
struct MoviesListViewModelActions {
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

/// ViewModel의 로딩 상태를 나타내는 열거형
/// - fullScreen: 전체 화면 로딩 상태
/// - nextPage: 다음 페이지 로딩 상태
enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

/// ViewModel이 입력받을 동작들을 정의한 프로토콜
protocol MoviesListViewModelInput {
    func viewDidLoad() // View가 로드되었을 때 호출
    func didLoadNextPage() // 다음 페이지를 로드할 때 호출
    func didSearch(query: String) // 검색 실행 시 호출
    func didCancelSearch() // 검색 취소 시 호출
    func showQueriesSuggestions() // 검색어 제안 목록을 보여줄 때 호출
    func closeQueriesSuggestions() // 검색어 제안 목록을 닫을 때 호출
    func didSelectItem(at index: Int) // 특정 아이템을 선택할 때 호출
}

/// ViewModel의 출력 프로퍼티들을 정의한 프로토콜
protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get } // 영화 리스트 아이템들
    var query: Observable<String> { get } // 현재 검색어
    var error: Observable<String> { get } // 오류 메시지
    var isEmpty: Bool { get } // 데이터 비어 있는지 여부
    var screenTitle: String { get } // 화면 제목
    var emptyDataTitle: String { get } // 데이터 비었을 때의 타이틀
    var errorTitle: String { get } // 오류 발생 시 타이틀
    var searchBarPlaceholder: String { get } // 검색창 플레이스홀더
}

/// ViewModel의 Input과 Output을 통합한 타입 별칭
typealias MoviesListViewModel = MoviesListViewModelInput & MoviesListViewModelOutput

final class DefaultMoviesListViewModel {
    
    // MARK: - Dependencies
    private let searchMoviesUseCase: SearchMoviesUseCase // 영화 검색 UseCase 의존성
    private let action: MoviesListViewModelActions? // 사용자 액션에 대한 의존성
    
    
    // MARK: - Pagination
    
    var currentPage: Int = 0 // 현재 페이지
    var totalPageCount: Int = 1 // 총 페이지 수
    var hasMorePages: Bool {
        currentPage < totalPageCount // 페이지가 남았는지 여부
    }
    var nextPage: Int {
        hasMorePages ? currentPage + 1 : currentPage // 다음 페이지를 계산
    }
    
    private var pages: [MoviesPage] = [] // 가져온 페이지 목록
    private var moviesLoadTask: Cancellable? { // 로드 작업을 취소 가능하게 관리
        willSet {
            moviesLoadTask?.cancel()
        }
    }
    private let mainQueue: DispatchQueue // 메인 스레드 실행 큐
    
    // MARK: - OUTPUT
    
    let items: Observable<[MoviesListItemViewModel]> = Observable([]) // 영화 리스트 아이템들
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none) // 로딩 상태
    let query: Observable<String> = Observable("") // 검색어
    let error: Observable<String> = Observable("") // 오류 메시지
    var isEmpty: Bool { return items.value.isEmpty } // 아이템 비어있는지 여부
    let emptyDataTitle = NSLocalizedString("Search results", comment: "") // 데이터 비어있을 때 타이틀
    let errorTitle = NSLocalizedString("Error", comment: "") // 오류 발생 시 타이틀
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "") // 검색창 플레이스홀더
    
    // MARK: - Init
    
    init(searchMoviesUseCase: SearchMoviesUseCase,
         action: MoviesListViewModelActions?,
         mainQueue: DispatchQueue) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.action = action
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private Methods
    
    /// 페이지 데이터를 추가하고 ViewModel을 업데이트
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        pages = pages
            .filter { $0.page != moviesPage.page }
        + [moviesPage]
        
        items.value = pages.movies.map(MoviesListItemViewModel.init)
    }
    
    /// 페이지와 아이템 데이터를 초기화
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    /// 영화 검색 로드 로직
    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        query.value = movieQuery.query
        
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            }, completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                        self?.loading.value = .none
                    }
                }
            })
    }
    
    /// 오류 처리 메서드
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
        NSLocalizedString("No internet connection", comment: "") :
        NSLocalizedString("Failed loading movies", comment: "")
    }
    
    /// 영화 쿼리 업데이트 및 로드
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
}

// MARK: - Array Extension

private extension Array where Element == MoviesPage {
    /// 모든 페이지의 영화를 평탄화하여 반환
    var movies: [Movie] { flatMap { $0.movies } }
}
