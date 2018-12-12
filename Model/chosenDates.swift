//
//  chosenDates.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 10/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import Foundation
import RealmSwift


class chosenDates: Object {
    
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?

    
}
