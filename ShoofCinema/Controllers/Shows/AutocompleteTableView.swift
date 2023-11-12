//
//  AutocompleteUICollectionView.swift
//  ShoofCinema
//
//  Created by mac on 3/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit

protocol AutocompleteTableViewDelegate : AnyObject {
    func didSelect(autocomplete: ShoofAPI.Autocomplete)
}


class AutocompleteTableView: UITableView {

    var autocomplete: [ShoofAPI.Autocomplete] = []
    
    weak var autocompleteDelegate : AutocompleteTableViewDelegate?
    
    
    init(frame: CGRect) {
        super.init(frame: .zero, style: .grouped)
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTableView()
    }
    
    private func setupTableView() {
        backgroundColor = Theme.current.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        keyboardDismissMode = .interactive
        register(UINib(nibName: "AutocompleteCell", bundle: nil), forCellReuseIdentifier: "AutocompleteCell")
        delegate  = self
        dataSource = self
    }

}

extension AutocompleteTableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocomplete.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteCell", for: indexPath) as! AutocompleteCell
        
        let autocomplete = autocomplete[indexPath.row]
        cell.configure(autocomplete: autocomplete)
        print("cell")
        
        return cell
    }
    
    // HEIGHT
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // WILL SELECT
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let t = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [t], with: .none)
        }
        return indexPath
    }
    
    // DID SELECT
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.autocompleteDelegate?.didSelect(autocomplete: autocomplete[indexPath.row])
    }
}



// MARK: - STRINGS
fileprivate extension String {
    static let autocompleteCellNibName = "AutocompleteCell"
}
