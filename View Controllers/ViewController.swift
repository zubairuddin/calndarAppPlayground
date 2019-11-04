//
//  ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import EventKit
import SwiftyJSON
import Alamofire
import FirebaseMessaging


var availabilitySummaryArray = [[Any]]()
var fractionResults = [[Any]]()
var noResultsArrayGlobal = [Int]()

//Zubair: The View Controller class should be named according to the function it performs
class  ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //    variables for the apple event calendar
    
    var calendarArray = [EKEvent]()
    var calendarEventArray : [Event] = [Event]()
    
    //    variables for the search dates chosen
    let dateFormatter = DateFormatter()
    let dateFormatterSimple = DateFormatter()
    let dateFormatterForResults = DateFormatter()
    let dateFormatterForResultsCreateEvent = DateFormatter()
    let dateFormatterTime = DateFormatter()
    let dateFormatterTZ = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    var startDateEnd = Date()
    var startDateGetEvent = Date()
    var endDateGetEvent = Date()
    var startEndDateGetEvent = Date()
    var isAllDay: Bool = false
    var selectedCalendars: [EKCalendar]?
    var source = ""
    var userIDArray = Array<String>()
    var userNameArray = Array<String>()
    var myAddedUserName = ""
    var ref: DocumentReference? = nil
    var myAddedUserID: String = ""
    var eventCreationID: String = ""
    var textPassedOver : String?
    var contactsList = [contactList]()
    var selectedContacts: [String] = [""]
    var numberOfItems = 1
    var datesBetweenChosenDatesStart = Array<Date>()
    var datesBetweenChosenDatesEnd = Array<Date>()
    var datesOfTheEvents = Array<Date>()
    var startDatesOfTheEvents = Array<Date>()
    var startEndDate = Date()
    var finalAvailabilityArray = Array<Int>()
    var eventLocation = ""
    var eventDescription = ""
    var eventOwnerName = ""

    
//    the variables below are the required variables for the event search
    var startDateInput = String()
    var endDateInput = String()
    var startTimeInput = String()
    var endTimeInput = String()


//    variable for refreshing the UITableViews on pull down
    var refreshControlCreated   = UIRefreshControl()
    
    
    var buttonHidden = false
    
    
//    Table views for invited and created events
    @IBOutlet var userCreatedEvents: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: "Circle",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        navTitle.append(NSMutableAttributedString(string: "it",
                                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        navLabel.attributedText = navTitle
        
        self.navigationItem.titleView = navLabel
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor.black
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
//        setting to allow the add event image to be used as a button
        
        
        print(user!)
        userCreatedEvents.delegate = self
        userCreatedEvents.dataSource = self
        userCreatedEvents.rowHeight = 80
        self.userCreatedEvents.separatorStyle = UITableViewCell.SeparatorStyle.none
        
//        get the events created by the user to display in the tableview
        getUsersCreatedEvents()
  
        dbStore.settings = settings

//        capital HH denotes the 24hr clock
        
        //Zubair: I would suggest creating custom class for your dateFormatters too since they are used at multiple places
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterForResultsCreateEvent.dateFormat = "E d MMM HH:mm"
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForResults.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForResultsCreateEvent.locale = Locale(identifier: "en_US_POSIX")
        startDate = dateFormatter.date(from: startDateInput + " " + startTimeInput) ?? dateFormatter.date(from: "2019-01-01 00:00")!
        
//        these two elements must contain the same time HH:mm:ss
        startEndDate = dateFormatter.date(from: startDateInput + " " + endTimeInput) ?? dateFormatter.date(from: "2019-01-01 00:00")!
        endDate = dateFormatter.date(from: endDateInput + " " + endTimeInput) ?? dateFormatter.date(from: "2019-01-01 00:00")!
        
        
        
// Refresh control add in tableview.
        refreshControlCreated.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlCreated.addTarget(self, action: #selector(refreshCreated), for: .valueChanged)
        self.userCreatedEvents.addSubview(refreshControlCreated)

//        The end of the viewDidLoad
    }
    

    
    //    function to get any updated data once the table is pulled down
    @objc func refreshCreated(_ sender: Any) {
        
        getUsersCreatedEvents()
        refreshControlCreated.endRefreshing()

    }

   
    //    determines what day of the week the date is
    func getDayOfWeek(_ today:String) -> Int? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
//        print("weekday \(weekDay)")
        return weekDay
    }
    
    
//    function for pulling down the array containing the days of the week our event can be on
    func getDayOfTheWeekArray(eventID: String){
        
        //Zubair: Write firebase stuff inside your global firebase manager
        let docRef = dbStore.collection("eventRequests").document(eventID)
        print(eventID)
        
        docRef.getDocument(
            completion: { (document, error) in
                if error != nil {
                    print("Error getting documents")
                }
                else {
                    
                    daysOfTheWeek = document?.get("daysOfTheWeek") as? [Int] ?? [10,10,10,10,10,10,10]

                }})}
    
    
    //    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDates() {
        
        datesBetweenChosenDatesStart.removeAll()
        var currentDate = startDate
        let calendar = NSCalendar.current
        
        //        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {

            let myDateString = dateFormatter.string(from: currentDate)
            let dayOfWeek = getDayOfWeek(myDateString)! - 1
            print(dayOfWeek)
            
            if daysOfTheWeek.contains(dayOfWeek) {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesStart.append(myDateNonString!)
                print(datesBetweenChosenDatesStart)
                
                
                                print(myDateString)
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
            
            let dayOfWeek = getDayOfWeek(myDateString)! - 1
            
            if daysOfTheWeek.contains(dayOfWeek) {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesEnd.append(myDateNonString!)
//                print(myDateString)
                
            }
            else {
                
                
            }
            
            //            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    
    
    //    MARK: code to pull down the events created by the user and display them
    @objc
    func getUsersCreatedEvents(){
        
        userEventList.removeAll()
        userEventListSorted.removeAll()
        
        //Zubair: Write firebase stuff inside your global firebase manager
        dbStore.collection("eventRequests").whereField("eventOwner", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    
                    
                    var nextUserEventToAdd = eventSearch()
                    
                    let startTimeString = document.get("startTimeInput") as! String
                    let adjStartTimeDate = self.dateFormatterTime.date(from: startTimeString)!.addingTimeInterval(TimeInterval(secondsFromGMT))
                    let adjStartTimeString = self.dateFormatterTime.string(from: adjStartTimeDate)
                    let endTimeString = document.get("endTimeInput") as! String
                    let adjEndTimeDate = self.dateFormatterTime.date(from: endTimeString)!.addingTimeInterval(TimeInterval(secondsFromGMT))
                    let adjEndTimeString = self.dateFormatterTime.string(from: adjEndTimeDate)
                    
                    nextUserEventToAdd.eventDescription = document.get("eventDescription") as! String
                    nextUserEventToAdd.eventStartTime = adjStartTimeString
                    nextUserEventToAdd.eventEndTime = adjEndTimeString
                    nextUserEventToAdd.eventLocation = document.get("location") as! String
                    nextUserEventToAdd.eventEndDate = document.get("endDateInput") as! String
                    nextUserEventToAdd.eventStartDate = document.get("startDateInput") as! String
                    nextUserEventToAdd.timeStamp = document.get("timeStamp") as? Float ?? 0.0
                    nextUserEventToAdd.eventID = document.documentID
                    nextUserEventToAdd.eventOwnerID = document.get("eventOwner") as! String
                    nextUserEventToAdd.eventOwnerName = document.get("eventOwnerName") as! String
                    
                    
                    userEventList.append(nextUserEventToAdd)
                    print("userEventList \(userEventList)")
                    
                    userEventListSorted = userEventList.sorted(by: {$0.timeStamp > $1.timeStamp})
                
                }
                self.userCreatedEvents.reloadData()
                
            }}}
    

    
//    reloads the table views whenever the page apears, this ensures it refreshes when a user creates a new event
    override func viewWillAppear(_ animated: Bool) {
        userCreatedEvents.reloadData()
    }
    
    
    //Zubair: It would be much better if delegate and datasource methods are written within extensions.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows = 1
        
//        numberOfRows = userEventList.count

        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item: eventSearch
        
            guard let cell = userCreatedEvents.dequeueReusableCell(withIdentifier: "userEventCell", for: indexPath) as? UserCreatedEventsCell
                else{
                    fatalError("failed to create user created events cell")
        }
        
        if userEventList.count == 0{
            
            cell.userCreatedCellLabel1.text = "You haven't created any events"
            cell.userCreatedCellLabel2.text = "Head to 'Create An Event' to get started"
            
            
            cell.userCreatedCellLabel1.adjustsFontSizeToFitWidth = true
            cell.userCreatedCellLabel2.adjustsFontSizeToFitWidth = true
            cell.userCreatedCellLabel3.text = ""
            
        }
        else{
        
        
        item = userEventListSorted[indexPath.section]
        let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
            eventTitleDescription.append(NSMutableAttributedString(string: " \(item.eventOwnerName)",
                                                               attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]))
            
            cell.userCreatedCellLabel1.attributedText = eventTitleDescription
        cell.userCreatedCellLabel2.text = ("Location: \(item.eventLocation) \nTime: \(item.eventStartTime) - \(item.eventEndTime)")
        
        cell.userCreatedCellLabel3.text = ("Time: \(item.eventStartTime) - \(item.eventEndTime)")
        
        //Zubair: This shouldn't be a part of UIViewController, you can write this your custom cell class
        cell.userCreatedCellLabel1.adjustsFontSizeToFitWidth = true
        cell.userCreatedCellLabel2.adjustsFontSizeToFitWidth = true
        cell.userCreatedCellLabel3.adjustsFontSizeToFitWidth = true
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.clipsToBounds = true
          
//        Removed whilst testing the string process
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            
        }
        
            return cell
 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSections = userEventList.count
        
        if numberOfSections == 0{
        numberOfSections = 1
        print("numberOfSections 1: \(numberOfSections)")
            
        }
        else{
            print("numberOfSections: \(numberOfSections)")
            
        }

        return numberOfSections
    }
    
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 20
        return cellSpacingHeight
    }
        
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.section)!")
        eventResultsArrayDetails.removeAll()
        anyArray.removeAll()
        
            selectEventToggle = 1
            let info = userEventListSorted[indexPath.section]
            print(info)
            eventIDChosen = info.eventID
        
        //        gets all the event details needed to create the event detail arrays
        addDatesToResultQuery2(eventID: eventIDChosen, selectEventToggle: 0){ (arrayForEventResultsPage, arrayForEventResultsPageDetails, numberOfDatesInArray)  in
            
            
            
            let noResultsArrayGlobal = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).noResultsArray
            let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).nonUserArray
            
            self.addUserToEventArray2(eventID: eventIDChosen, noResultArray: noResultsArrayGlobal){ (arrayForEventResultsPageAvailability) in
                
                self.addNonExistentUsers(eventID: eventIDChosen, noResultArray: nonUserArray){ (addNonExistentUsersAvailability, nonExistentNames) in
                
                    eventResultsArrayDetails = arrayForEventResultsPageDetails + [nonExistentNames]
                    print("eventResultsArrayDetails \(eventResultsArrayDetails)")
                    
                    let resultsSummary = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).countedResults
                    
                    fractionResults = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).fractionResults
                    
                    
                    
                    availabilitySummaryArray = resultsSummary
                    
                    print("resultsSummaryArray: \(resultsSummary)")
                    
                    
                arrayForEventResultsPageFinal = arrayForEventResultsPage + resultsSummary + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability
                print("arrayForEventResultsPageFinal \(arrayForEventResultsPageFinal)")
                
                
                self.performSegue(withIdentifier: "eventResultsCreated", sender: self)
                
                
            }
            }
            
        }
        

    }
    
//    used to determine whether the delete button should be visible on the event results page, the button is set to hidden for the events we were invited to. The buttons natural state is visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "eventResultsInvited") {
            let destinationController = segue.destination as! ViewController2
            destinationController.buttonHidden = true
        }
    }
    
    
//    used to set the carrier, battery and time colour to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}


