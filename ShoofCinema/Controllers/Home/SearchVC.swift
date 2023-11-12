//
//  SearchVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/15/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class SearchVC: MasterVC {
    
    // MARK: - LINKS + VIEWS
    @IBOutlet weak var searchTextField : SearchTextField!
    @IBOutlet weak var clearButton : MainButton!
    @IBOutlet weak var collectionViewContainer : UIView!
    var collectionView : ShowsCollectionView!
    var autocompleteTableView: AutocompleteTableView!
    
    let searchBar = UISearchController()
    
    // MARK: - VARS
//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.showsDelegate = self
//        return m
//    }()

    let shoofAPI: ShoofAPI = .shared
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        collectionView = ShowsCollectionView(frame: view.bounds, scrollDirection: .vertical)
        autocompleteTableView = AutocompleteTableView(frame: view.bounds)
        autocompleteTableView.autocompleteDelegate = self
        collectionView.showsDelegate = self
        setupSubViews()
        searchBarConfig()
        self.shoofAPI.loadSuggestedShows(pageNumber: 1) { [weak self] result in
            self?.suggestedShowsAPIResponse(result: result)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.isActive = true
        searchBar.searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
//            title = " "
    }
    
    
    // MARK: - PRIVATE
    private func setupSubViews() {
        clearButton.isHidden = true
        collectionViewContainer.addSubview(collectionView)
        collectionView.snp.makeConstraints({
            $0.size.equalToSuperview()
        })
        collectionViewContainer.addSubview(autocompleteTableView)
        autocompleteTableView.snp.makeConstraints({
            $0.size.equalToSuperview()
        })
    }
    
    private func searchBarConfig() {
        searchBar.searchBar.barStyle = .black
        searchBar.searchBar.keyboardAppearance = .dark
        searchBar.searchBar.delegate = self
        searchBar.searchResultsUpdater = self
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        navigationItem.searchController = searchBar
    }
    
    
    private func setupTextField () {
        self.searchTextField.keyboardAppearance = .dark
        self.searchTextField.delegate = self
        self.searchTextField.returnKeyType = .search
        //searchTextField.becomeFirstResponder()
        searchTextField.addTarget(self, action: #selector(clearButtonState), for: .editingChanged)
    }
    
    @objc private func clearButtonState () {
        clearButton.isHidden = searchTextField.text?.count == 0 ? true : false
    }
    
    
    private func searchTextFieldIsActive(_ state : Bool) {

        if !state {
            view.endEditing(true)
        }
        self.collectionView.isHidden = state
        self.autocompleteTableView.isHidden = !state
    }
    
    func autocompleteAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Autocomplete]>.Response, Error>) {
        do {
            let response = try result.get()
            DispatchQueue.main.async {
                if let search = self.searchBar.searchBar.text, search.count > 0 {
                    self.autocompleteTableView.autocomplete = response.body
                    self.autocompleteTableView.reloadData()
                }
            }
        }  catch is URLError {
            DispatchQueue.main.async {
                self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                print("Auto complete errors")
            }
        }
    }
    
    func suggestedShowsAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Autocomplete]>.Response, Error>) {
        do {
            let response = try result.get()
            DispatchQueue.main.async {
                if let search = self.searchTextField.text, search.count == 0 {
                    self.autocompleteTableView.autocomplete = response.body
                    self.autocompleteTableView.reloadData()
                }
            }
        }  catch is URLError {
            DispatchQueue.main.async {
                self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                print("Auto complete errors")
            }
        }
    }
    
    // MARK: - ACTIONS

    @IBAction func clearButtonTapped() {
        searchTextField.text = ""
        searchTextFieldIsActive(true)
        self.shoofAPI.loadSuggestedShows(pageNumber: 1) { [weak self] result in
            self?.suggestedShowsAPIResponse(result: result)
        }

    }

}

// MARK: - SHOWS COLLECTION
extension SearchVC : ShowsCollectionViewDelegate {
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Show]>.Response, Error>) {
        do {
            let response = try result.get()
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.view.hideNoContentView()
                self.collectionView.loadShows(shows: response.body, isLastPage: response.isOnLastPage)
            }
        }  catch is URLError {
            DispatchQueue.main.async {
                self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                self.collectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .noMatchesMessage, imageName: .sadFaceIcon, actionButtonTitle: nil, action: nil)
            }
        }
    }
    
    func showsCollectionView(_ colelctionView: ShowsCollectionView, shouldLoadPage pageNumber: Int, withFilter filter: ShoofAPI.Filter) {
        
        guard let searchKeyword = searchBar.searchBar.text else { return }
        
        var isMovie: Bool? {
            switch filter.mediaType {
            case.all:
                return nil
            case.movies:
                return true
            case .series:
                return false
            }
        }
        
//        shoofAPI.searchShows(withKeywords: searchKeyword, genreID: filter.genreID, releaseYear: filter.year, isMovie: isMovie, pageNumber: pageNumber) { [weak self] result in
//            self?.handleAPIResponse(result: result)
//        }
        
//        networkManager.getShowsBySearch(keyword: searchKeyword, page: page, sorting: sort, sortingType: sortType, year: year, genre: genre)

    }

    func showNoContentView() {
        collectionView.showNoContentView(with: .genericErrorTitle, .noMatchesMessage, and: UIImage(named: .sadFaceIcon)!, actionButtonTitle: .tryAgainButtonTitle)
    }
}


extension SearchVC : UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextFieldIsActive(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            searchTextFieldIsActive(false)
            
            collectionView.reloadWithFilter()
        }
        return true
    }
    
}


extension SearchVC : AutocompleteTableViewDelegate {
    
    func didSelect(autocomplete: ShoofAPI.Autocomplete) {
        self.searchTextFieldIsActive(false)
        searchBar.searchBar.text = autocomplete.title
        searchBar.searchBar.endEditing(true)
        self.collectionView.reloadWithFilter()
        
        if let showId = autocomplete.showId {
            self.shoofAPI.increaseSearchCount(showId: showId) { result in
                print("increaseSearchCount", result)
            }
        }
        

    }
}


// MARK: - NETWORK DELEGATE
extension SearchVC {
    
    func requestEnded() {
        
    }
     
    func failure() {
        tabBar?.alert.genericError()
    }
    
    func noData() {
        
        collectionView.showNoContentView(with: .genericErrorTitle, .noMatchesMessage, and: UIImage(named: .sadFaceIcon)!, actionButtonTitle: .tryAgainButtonTitle)

    }
    
    func success(result: ShowsLoadingSuccessResult) {
        collectionView.isHidden = false
        view.hideNoContentView()
//        collectionView.successBlock(result: result)
    }
}


extension SearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTextFieldIsActive(false)
        
        collectionView.reloadWithFilter()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTextFieldIsActive(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchTextFieldIsActive(true)
    }
}

extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       
        guard let searchKeyword = searchController.searchBar.text else {
            autocompleteTableView.reloadData()
            return
        }
        
        
        
        if searchKeyword.count == 0 {
            self.shoofAPI.loadSuggestedShows(pageNumber: 1) { [weak self] result in
                self?.suggestedShowsAPIResponse(result: result)
            }
            autocompleteTableView.reloadData()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.shoofAPI.autocomplete(showName: searchKeyword) { [weak self] result in
                self?.autocompleteAPIResponse(result: result)
            }
        }
        
    }
}
