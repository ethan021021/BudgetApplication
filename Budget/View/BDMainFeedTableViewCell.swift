//
//  BDMainFeedTableViewCell.swift
//  Budget
//
//  Created by Diamond on 2/13/18.
//  Copyright © 2018 Diamond. All rights reserved.
//

import UIKit

class BDMainFeedTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = UIColor.white
        self.detailTextLabel?.textColor = UIColor.white
        self.textLabel?.textAlignment = .center
        self.detailTextLabel?.textAlignment = .center
        self.layer.cornerRadius = 10.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
