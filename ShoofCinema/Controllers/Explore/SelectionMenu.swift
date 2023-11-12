//
//  SelectionMenuViewController.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/24/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation
import UIKit

fileprivate let identifier = "SelectionCell"

protocol MenuSelection where Self : Equatable {
    var localizedString : String { get }
}

protocol SelectionMenuDelegate : AnyObject {
    func selectionMenu<S>(_ selectionMenu: SelectionMenu<S>, didSelect item: S)
}

class SelectionMenu<Selection : MenuSelection> : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentSelection: Selection?
    var values: [Selection] = []
    
    weak var delegate: SelectionMenuDelegate?
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(SelectionCell.self, forCellReuseIdentifier: identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Theme.current.secondaryColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let currentSelection = currentSelection, let indexPath = indexPath(for: currentSelection) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! SelectionCell
        let selection = values[indexPath.row]
        cell.textLabel?.text = selection.localizedString
        cell.textLabel?.textColor = Theme.current.textColor
        cell.backgroundColor = Theme.current.secondaryColor
        cell.tintColor = Theme.current.tintColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = values[indexPath.row]
        self.currentSelection = selection
        delegate?.selectionMenu(self, didSelect: selection)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.indexPathsForSelectedRows?.forEach { indexPath in
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        return indexPath
    }
    
    private func indexPath(for item: Selection) -> IndexPath? {
        if let index = values.firstIndex(of: item) {
            return IndexPath(row: index, section: 0)
        }
        
        return nil
    }
}

class SelectionCell : UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}
