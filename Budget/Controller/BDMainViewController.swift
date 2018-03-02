//
//  ViewController.swift
//  Budget
//
//  Created by Diamond on 12/30/17.
//  Copyright © 2017 Diamond. All rights reserved.
//

import UIKit
import RealmSwift

let cellIdentifier = "cell"
let settingsSegueIdentifier = "segueToSettings"

class BDMainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = RealmManager.sharedInstance.realm
    
    var dataSource: Results<DeducatedAmount>?
    var budgetSub: Float?
    var currentBudget: Float!
    var userUpdatedMainBudget = false
    
    // MARK: View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = self.tableView.backgroundColor
        self.tableView.register(BDMainFeedTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.tableFooterView = UIView.init()
        self.tableView.allowsSelection = false
        
        let currentBudgetFromDefaults = UserDefaults.standard.float(forKey: "balance")
        
        if (currentBudgetFromDefaults != 0) {
            
            // Set users current budget for view controller
            self.currentBudget = currentBudgetFromDefaults
            
            // Set title bar to current budget value
            let deductedAmounts = self.realm.objects(DeducatedAmount.self)
            self.title = self.calculateBudgetAmount(deducatedAmounts: deductedAmounts)
        }
        
        // Navigation bar setup
        let organizeButton = UIBarButtonItem.init(barButtonSystemItem: .organize, target: self, action: #selector(self.didTapSettings))
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.didTapAddDeductedAmount))
        
        organizeButton.tintColor = UIColor.white
        addButton.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = organizeButton
        self.navigationItem.leftBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.userUpdatedMainBudget) {
            do {
                try self.realm.write {
                    self.realm.deleteAll()
                }
            } catch let err {
                print("error deleting all objects from realm after updating master balance: \(err)")
            }
            
            self.tableView.reloadData()
            self.currentBudget = UserDefaults.standard.float(forKey: "balance")
            self.updateTitleToCurrentBalance(currentBudgetAmount: self.currentBudget)
        }
        
        self.setupTableViewDataSource()
        
        self.userUpdatedMainBudget = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Datsource methods
    private func setupTableViewDataSource() {
        let amountsFromRealm = self.realm.objects(DeducatedAmount.self)
        
        self.dataSource = amountsFromRealm
    }
    
    private func calculateBudgetAmount(deducatedAmounts: Results<DeducatedAmount>) -> String {
        var mainBudget = UserDefaults.standard.float(forKey: "balance")
        for amount in deducatedAmounts {
            mainBudget = mainBudget - Float.init(amount.amount.description)!
        }
        
        return "$\(mainBudget)"
    }

    // MARK: Selectors
    
    @objc func didTapSettings() {
        self.performSegue(withIdentifier: settingsSegueIdentifier, sender: nil)
    }
    
    @objc func didTapAddDeductedAmount() {
        let addAmountAlertController = UIAlertController.init(title: "How much did you spend?", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction.init(title: "Add amount", style: .default) { (action) in
            guard let textField = addAmountAlertController.textFields?[0] else { return }
            guard let secondTextField = addAmountAlertController.textFields?[1] else { return }
            
            if let text = textField.text {
                
                // Check data for description of what was added to deducted amount
                if (secondTextField.text == "") {
                    let errorAlertController = UIAlertController.init(title: "Sorry!", message: "You can't enter an empty description for the description of the deducated amount. We need to know what you're buying!", preferredStyle: .alert)
                    errorAlertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    self.present(errorAlertController, animated: true, completion: nil)
                    
                    return
                }
                
                guard let itemDescription = secondTextField.text else { return }
                
                // Parse data for added deducted amount
                guard let textFloat = Float.init(text) else { return }
                
                if (textFloat > self.currentBudget) {
                    let errorAlertController = UIAlertController.init(title: "Sorry!", message: "That value is above your current budget we are taking from please enter a value that is lower than the current budget displayed.", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                    errorAlertController.addAction(okAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                    
                    return
                }
                
                let returnedBalance = self.deductFromBalance(amount: textFloat, balance: self.currentBudget)
                
                let deductedAmount = DeducatedAmount()
                deductedAmount.amount = textFloat
                deductedAmount.itemDescription = itemDescription
                
                do {
                    try self.realm.write {
                        self.realm.add(deductedAmount)
                    }
                } catch let err {
                    print("error writing amount to realm: \(err)")
                }
                
                self.updateTitleToCurrentBalance(currentBudgetAmount: returnedBalance)
                
                self.tableView.reloadData()
            }
        }
        
        addAmountAlertController.addAction(addAction)
        
        addAmountAlertController.addTextField { (textField) in
            textField.placeholder = "How much did you spend?"
        }
        addAmountAlertController.addTextField { (textField) in
            textField.placeholder = "What did you spend it on?"
        }
        
        present(addAmountAlertController, animated: true, completion: nil)
    }
    
    // MARK: UI Helpers
    
    private func deductFromBalance(amount: Float, balance: Float) -> Float {
        let calculatedAmount = balance - amount
        self.currentBudget = calculatedAmount
        return calculatedAmount
    }
    
    private func addBackToBalance(amount: Float, balance: Float) -> Float {
        let calculatedAmount = balance + amount
        self.currentBudget = calculatedAmount
        return calculatedAmount
    }
    
    private func updateTitleToCurrentBalance(currentBudgetAmount: Float) {
        if (currentBudgetAmount <= 0.0) {
            self.title = "Congratulations you're broke!"
            
            return
        }
        
        self.title = "$\(currentBudgetAmount)"
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
        if let dataSource = self.dataSource {
            return dataSource.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let dataSource = self.dataSource {
            let amount = dataSource[indexPath.section]
            let calculatedAmount = self.addBackToBalance(amount: amount.amount, balance: self.currentBudget)
            
            do {
                try realm.write {
                    realm.delete(amount)
                }
                
                UserDefaults.standard.set(calculatedAmount, forKey: "balance")
                
                self.updateTitleToCurrentBalance(currentBudgetAmount: calculatedAmount)
            } catch let err {
                print("error removing row from realm: \(err)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.backgroundColor = UIColor(red: 0.80, green: 0.54, blue: 0.97, alpha: 1.00)
        
        if let dataSource = self.dataSource {
            cell.textLabel?.text = "$\(dataSource[indexPath.section].amount.description)"
            cell.detailTextLabel?.text = dataSource[indexPath.section].itemDescription
        }
        
        return cell
    }
}

