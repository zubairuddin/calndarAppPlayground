//
//  File.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 10/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import Foundation
import RealmSwift
import EventKit

class CalendarEventRealm1: Object {
    @objc dynamic var title: String? = ""
    @objc dynamic var location: String = ""
    @objc dynamic var calendar: String? = ""
    @objc dynamic var alarms: String? = ""
    @objc dynamic  var URL: String? = ""
    @objc dynamic var lastModified: Date?
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var allDay: Bool = false
    @objc dynamic var floating: String = ""
    @objc dynamic var recurrence: String? = ""
    @objc dynamic var attendees: String? = ""
    @objc dynamic var timezone: String? = ""
    @objc dynamic var occuranceDate: Date?
    @objc dynamic var eventIdentifier: String? = ""
}
