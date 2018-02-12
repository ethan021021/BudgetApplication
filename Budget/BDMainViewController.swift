//
//  ViewController.swift
//  Budget
//
//  Created by Diamond on 12/30/17.
//  Copyright © 2017 Diamond. All rights reserved.
//

import UIKit

let cellIdentifier = "cell"
let settingsSegueIdentifier = "segueToSettings"

class BDMainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [Float]()
    var budgetSub: Float?
    var currentBudget: Float!
    var userUpdatedMainBudget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView.init()
        self.tableView.allowsSelection = false
        
        let currentBudgetFromDefaults = UserDefaults.standard.float(forKey: "balance")
        
        if (currentBudgetFromDefaults != 0) {
            
            // Set users current budget for view controller
            self.currentBudget = currentBudgetFromDefaults
            
            // Set title bar to current budget value
            self.updateTitleToCurrentBalance(currentBudgetAmount: currentBudgetFromDefaults)
        }
        
        // Navigation bar setup
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .organize, target: self, action: #selector(self.didTapSettings))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.didTapAddDeductedAmount))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.userUpdatedMainBudget) {
            self.dataSource.removeAll()
            self.tableView.reloadData()
            self.currentBudget = UserDefaults.standard.float(forKey: "balance")
            self.updateTitleToCurrentBalance(currentBudgetAmount: self.currentBudget)
        }
        
        self.userUpdatedMainBudget = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Selectors
    
    @objc func didTapSettings() {
        self.performSegue(withIdentifier: settingsSegueIdentifier, sender: nil)
    }
    
    @objc func didTapAddDeductedAmount() {
        let addAmountAlertController = UIAlertController.init(title: "How much did you spend?", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction.init(title: "Add amount", style: .default) { (action) in
            guard let textField = addAmountAlertController.textFields?[0] else { return }
            
            if let text = textField.text {
                guard let textFloat = Float.init(text) else { return }
                
                if (textFloat > self.currentBudget) {
                    let errorAlertController = UIAlertController.init(title: "Sorry!", message: "That value is above your current budget we are taking from please enter a value that is lower than the current budget displayed.", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                    errorAlertController.addAction(okAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                    
                    return
                }
                
                let returnedBalance = self.deductFromBalance(amount: textFloat, balance: self.currentBudget)
                
                self.dataSource.append(returnedBalance)
                
                self.updateTitleToCurrentBalance(currentBudgetAmount: returnedBalance)
                
                self.tableView.reloadData()
            }
        }
        
        addAmountAlertController.addAction(addAction)
        
        addAmountAlertController.addTextField(configurationHandler: nil)
        
        present(addAmountAlertController, animated: true, completion: nil)
    }
    
    // MARK: UI Helpers
    
    private func deductFromBalance(amount: Float, balance: Float) -> Float {
        let calculatedAmount = balance - amount
        self.currentBudget = calculatedAmount
        return calculatedAmount
    }
    
    private func updateTitleToCurrentBalance(currentBudgetAmount: Float) {
        self.title = String.init(currentBudgetAmount)
    }
    
    // MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BDSettingsTableViewController {
            destination.delegate = self
        }
    }
}

extension BDMainViewController: BDSettingsTableViewControllerDelegate {
    func userUpdatedTotalBudgetAmount() {
        self.userUpdatedMainBudget = true
        self.viewWillAppear(true)
    }
}

extension BDMainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if (self.dataSource.count > 0) {
            cell.textLabel?.text = self.dataSource[indexPath.row].description
        }
        
        return cell
    }
}

