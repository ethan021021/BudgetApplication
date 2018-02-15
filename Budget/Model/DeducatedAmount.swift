//
//  DeducatedAmount.swift
//  Budget
//
//  Created by Diamond on 2/13/18.
//  Copyright © 2018 Diamond. All rights reserved.
//

import Foundation
import RealmSwift

class DeducatedAmount: Object {
    @objc dynamic var amount: Float = 0.0
    @objc dynamic var itemDescription: String = ""
}
