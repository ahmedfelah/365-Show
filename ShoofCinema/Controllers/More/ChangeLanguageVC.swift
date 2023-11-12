//
//  ChangeLanguageVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 5/9/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class ChangeLanguageVC: MasterTVC {

    
    // MARK: - VARS
    private var languageHelper = LanguageHelper()

    
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func setupViews() {
        super.setupViews()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = Theme.current.tabbarColor
    }
    
    
    
    // MARK: - TABLE
    
    // ROWS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageHelper.codes.count
    }
    
    // CELLS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.tintColor = Theme.current.tintColor
        cell.textLabel?.text = languageHelper.localizedList[indexPath.row]
        cell.accessoryType = languageHelper.codes[indexPath.row] == languageHelper.getSelectedLanguageCode() ? .checkmark : .none
        return cell
    }
    
    // WILL SELECT
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedLanguageCode = languageHelper.codes[indexPath.row]
        if selectedLanguageCode == languageHelper.getSelectedLanguageCode() { return indexPath }
        
        tabBar?.alert.changeLanguageRestart { [weak self] in
            // change the language and quit the app
            self?.languageHelper.changeLanguageForIOS12(languageCode: selectedLanguageCode)
            exit(0)
        }
        return indexPath
    }
    
    // DID SELECT
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
