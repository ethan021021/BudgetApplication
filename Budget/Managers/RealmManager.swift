//
//  RealmManager.swift
//  Budget
//
//  Created by Diamond on 2/13/18.
//  Copyright © 2018 Diamond. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let sharedInstance = RealmManager()
    
    var realm: Realm = {
        var tmpRealm = try! Realm()
        debugPrint("Realm file location: \(tmpRealm.configuration.fileURL!)")
        return tmpRealm
    }()
}
