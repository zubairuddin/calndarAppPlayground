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
//    when the days of the week we are looking for are input inot the array, they should be input with their corrcet integer day, all other unrequired days should be input with a random integer e.g. 10 below
    var daysOfTheWeek = [10,1,2,10,10,10,10]
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
    var startDateInput = "2018-11-01"
    var endDateInput = "2018-12-31"
    var startTimeInput = "06:00"
    var endTimeInput = "16:00"
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //        select the time period for which we wish to search
        
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
//        capital HH denotes the 24hr clock
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDate = dateFormatter.date(from: startDateInput + " " + startTimeInput)!
        
        //        these two elements must contain the same time HH:mm:ss
        startEndDate = dateFormatter.date(from: startDateInput + " " + endTimeInput)!
            endDate = dateFormatter.date(from: endDateInput + " " + endTimeInput)!
        
        
        try! realm.write {
            realm.deleteAll()
        }
        
        print(endDate)
        print(startDate)
    
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
       
            if daysOfTheWeek.contains(dayOfWeek!) {
                
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
            
            
            if daysOfTheWeek.contains(dayOfWeek!) {
                
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
         n = n + 1

            }

            n = 0
            y = y + 1
        }
        print(finalAvailabilityArray)
        }
    

    }
