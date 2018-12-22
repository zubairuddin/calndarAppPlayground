//
//  EventsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 09/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift

class EventsViewController: UIViewController {

//    required to initiate realm
    let realm = try! Realm()
    var realmResults: Results<CalendarEventRealm1>!
    
//    variables for the apple event calendar
    var eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var calendarArray = [EKEvent]()
    var calendarEventArray : [Event] = [Event]()
    
    
//    variables for the search dates chosen
    let dateFormatter = DateFormatter()
    let dateFormatterSimple = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    var startDateEnd = Date()
    var isAllDay: Bool = false
    var daysOfTheWeek = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var selectedDaysOfTheWeek = Array<Any>()
    var numberOfItems = 1
    var datesBetweenChosenDatesStart = Array<Date>()
    var datesBetweenChosenDatesEnd = Array<Date>()
    var daysOfWeekBetweenChosenDatesEnd = Array<Date>()
    var dateComponents = DateComponents()
    var datesOfTheEvents = Array<Date>()
    var startDatesOfTheEvents = Array<Date>()
    var datesToCheckSet = Set<Date>()
    var datesToCheckArray = Array<Date>()
    var startEndDate = Date()
    
    var finalAvailabilityArray = Array<Int>()
    


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //        select the time period for which we wish to search
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
        startDate = dateFormatter.date(from: "2018-11-01 06:00:00 +0000")!
        startEndDate = dateFormatter.date(from: "2018-11-01 10:00:00 +0000")!
            endDate = dateFormatter.date(from: "2018-12-31 10:00:00 +0000")!
        
        try! realm.write {
            realm.deleteAll()
        }
        
        print(endDate)
        print(startDate)
        
        //        select the days we want to seach for
        
        selectedDaysOfTheWeek = [1,3]
        
    }
    


    @IBAction func runTheEventSearchCode(_ sender: UIButton) {
      
        
    
        
        checkCalendarStatus()
        requestAccessToCalendar()
        getCalendarData()
        getArrayOfChosenDates()
        getArrayOfChosenDatesEnd()
        compareTheEventTimmings()
        
        




        
    }
    
    
    func checkCalendarStatus(){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            print("We got access")
        case EKAuthorizationStatus.denied:
            print("No access")
            
        case .restricted:
            print("Access denied")
        }
        
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                print("we got access")
            }
            else{
                print("no access")
            }
            
        })
    }
    
    func getCalendarData()  {
        
        datesOfTheEvents.removeAll()
        startDatesOfTheEvents.removeAll()
        calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: calendars))
        
//        print(calendarArray)
        
      numberOfItems = calendarArray.count
        
//        print(numberOfItems)
        
        try! realm.write {
            realm.deleteAll()
        }
        

        
        for event in calendarArray{
            
//            appends new items into the array calendarEventsArray
        
        let newItemInArray = Event()
        newItemInArray.alarms = event.alarms
            newItemInArray.title = event.title
            newItemInArray.location = event.location!
            newItemInArray.URL = event.url
            newItemInArray.lastModified = event.lastModifiedDate
            newItemInArray.startDate = event.startDate
            newItemInArray.endDate = event.endDate
            newItemInArray.allDay = event.isAllDay
            newItemInArray.recurrence = event.recurrenceRules
            newItemInArray.attendees = event.attendees
            newItemInArray.timezone = event.timeZone
            newItemInArray.availability = event.availability
            newItemInArray.occuranceDate = event.occurrenceDate
            
            calendarEventArray.append(newItemInArray)
            
//            print(Event.init().title!)
            
            
//            writes the data into Realm
            
            do{
                
                try self.realm.write{
                    
                    let newItemInArrayRealm = CalendarEventRealm1()
                    newItemInArrayRealm.eventIdentifier = event.eventIdentifier
                    newItemInArrayRealm.title = event.title
                    newItemInArrayRealm.endDate = event.endDate
                    newItemInArrayRealm.startDate = event.startDate
                    newItemInArrayRealm.location = event.location!
                    newItemInArrayRealm.allDay = event.isAllDay
                    newItemInArrayRealm.occuranceDate = event.occurrenceDate
                    realm.add(newItemInArrayRealm)
                    
                }
                
//                creates an array of the dates on which the user has events
                datesOfTheEvents.append(event.occurrenceDate)
                startDatesOfTheEvents.append(event.startDate)
                
//                print(startDatesOfTheEvents)
                
                
//                prints the titles of the saved events
//                print(newItemInArray.title!)
            }
            catch {
                print("Error saving new items, \(error)")
                
            }
            
        }
        //                    location of the realm file
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
            
        }
    
    
    
//    determines what day of the week the date is
    func getDayOfWeek(_ today:String) -> Int? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    
//    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDates() {
        
        datesBetweenChosenDatesStart.removeAll()
        var currentDate = startDate
        let calendar = NSCalendar.current
        
//        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {
    
            
            
            let myDateString = dateFormatter.string(from: currentDate)
    
            let dayOfWeek = getDayOfWeek(myDateString)
       
            if dayOfWeek == 1 || dayOfWeek == 2 {
                
            let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesStart.append(myDateNonString!)
                

//                print(myDateString)
            }
            else {
                
            }
            
//            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    
    
    //    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDatesEnd() {
        
        datesBetweenChosenDatesEnd.removeAll()
        var currentDate = startEndDate
        let calendar = NSCalendar.current
        
        //        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {
            
            let myDateString = dateFormatter.string(from: currentDate)
            
            let dayOfWeek = getDayOfWeek(myDateString)
            
            if dayOfWeek == 1 || dayOfWeek == 2 {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesEnd.append(myDateNonString!)

            }
            else {

                
            }
            
            //            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    


    
    
//    compares the timmings of the events we have to those specified by the user and returns those dates we are free
    func compareTheEventTimmings (){

        let numeberOfDatesToCheck = datesBetweenChosenDatesStart.count - 1
        let numberOfEventDatesToCheck = startDatesOfTheEvents.count - 1
        var n = 0
        var y = 0
        finalAvailabilityArray.removeAll()


//      Get the event IDs for those events on the dates within datesToCheckArray

//        while n <= numeberOfDatesToCheck - 1 {

//        let theCurrentDate = datesToCheckArray[n]
//        let predicate = NSPredicate(format: "occuranceDate == %@",theCurrentDate as CVarArg)

        
        while y <= numeberOfDatesToCheck {
        
        while n <= numberOfEventDatesToCheck {
        
        if
              (datesBetweenChosenDatesStart[y] ... datesBetweenChosenDatesEnd[y]).contains(startDatesOfTheEvents[n]) == true {
            
            finalAvailabilityArray.append(0)
            
        }
        else {
            
            if n == numberOfEventDatesToCheck{
                finalAvailabilityArray.append(1)}

            
        }
//         print(datesBetweenChosenDatesStart[y])
//            print(datesBetweenChosenDatesEnd[y])
//            print(startDatesOfTheEvents[n])
         n = n + 1

            }

            n = 0
            y = y + 1
        }
        print(finalAvailabilityArray)
        


//        let currentEvent = realm.objects(CalendarEventRealm1.self).filter(predicate)

//        print(currentEvent)

//        n = n + 1

        }

    }
