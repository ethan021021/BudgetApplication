//
//  BDSettingsTableViewCell.swift
//  Budget
//
//  Created by Diamond on 12/30/17.
//  Copyright © 2017 Diamond. All rights reserved.
//

import UIKit

protocol BDSettingsTableViewCellDelegate {
    func didFinishEditingTextField(textField: UITextField)
}

class BDSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    var delegate: BDSettingsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textField.delegate = self
        self.textField.text = UserDefaults.standard.string(forKey: "balance") ?? "0.00"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension BDSettingsTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        self.delegate?.didFinishEditingTextField(textField: textField)
        return true
    }
}
