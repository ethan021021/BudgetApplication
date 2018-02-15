//
//  BDSettingsTableViewController.swift
//  Budget
//
//  Created by Diamond on 12/30/17.
//  Copyright © 2017 Diamond. All rights reserved.
//

import UIKit

let settingsCellIdentifier = "settingsCell"

protocol BDSettingsTableViewControllerDelegate {
    func userUpdatedTotalBudgetAmount()
}

class BDSettingsTableViewController: UITableViewController {
    
    var delegate: BDSettingsTableViewControllerDelegate?

    // MARK: View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "BDSettingsTableViewCell", bundle: nil), forCellReuseIdentifier: settingsCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    // MARK: Table view delegate methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellIdentifier, for: indexPath) as? BDSettingsTableViewCell else { return BDSettingsTableViewCell() }

        // Configure the cell...
        cell.delegate = self
            
        return cell
    }
}

extension BDSettingsTableViewController: BDSettingsTableViewCellDelegate {
    func didFinishEditingTextField(textField: UITextField) {
        UserDefaults.standard.set(textField.text ?? 0.00, forKey: "balance")
        self.delegate?.userUpdatedTotalBudgetAmount()
        let alertController = UIAlertController.init(title: "Saved", message: "We saved your balance information.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
