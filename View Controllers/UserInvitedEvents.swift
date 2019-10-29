//
//  UserInvitedEvents.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 02/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

class UserInvitedEvents: UIViewController, UITableViewDataSource, UITableViewDelegate {

//    general variables
    var startDate = Date()
    var endDate = Date()
    var datesBetweenChosenDatesStart = Array<Date>()
    var numberOfDatesInArray = 0
    var dateFormatterSimple = DateFormatter()
    var dateFormatterForResults = DateFormatter()
    var noResultsArray = Array<Any>()
    
//    variable for refreshing the UITableViews on pull down
    var refreshControlCreated   = UIRefreshControl()
    
//    date formatters
    var dateFormatter = DateFormatter()
    let dateFormatterTime = DateFormatter()
  
    
    @IBOutlet var userInvitedEvents: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigation bar setup
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
        self.userInvitedEvents.separatorStyle = UITableViewCell.SeparatorStyle.none

        
//        tableviewsetup
        userInvitedEvents.delegate = self
        userInvitedEvents.dataSource = self
        userInvitedEvents.rowHeight = 80
        
//        get the users invited events once the page loads
        getUsersInvtedEvents()
        
//        set date fromatters
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterTime.dateFormat = "HH:mm"
        
        
        
        // Refresh control add in tableview.
        refreshControlCreated.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlCreated.addTarget(self, action: #selector(refreshCreated), for: .valueChanged)
        self.userInvitedEvents.addSubview(refreshControlCreated)
        
        //        The end of the viewDidLoad
    }
    
    //    function to get any updated data once the table is pulled down
    @objc func refreshCreated(_ sender: Any) {
        
        print("user pulled to refresh the userinvited table")
        
        getUsersInvtedEvents()
        refreshControlCreated.endRefreshing()
        
    }
    
    
    
    //    MARK: code to pull down the events the user is invited to and display them
    @objc func getUsersInvtedEvents(){
        userInvitedEventList.removeAll()
        userInvitedEventListSorted.removeAll()
        var nextUserEventToAdd = eventSearch()
        dbStore.collection("eventRequests").whereField("users", arrayContains: user!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    //                                        print("\(document.documentID) => \(document.data())")
                    let eventOwner = document.get("eventOwner") as! String
                    
                    if  eventOwner == user {
                    }
                        
                    else{
                        
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
                        nextUserEventToAdd.eventID = document.documentID
                        nextUserEventToAdd.eventOwnerID = document.get("eventOwner") as! String
                        nextUserEventToAdd.eventOwnerName = document.get("eventOwnerName") as! String
                        
                        userInvitedEventList.append(nextUserEventToAdd)
                        userInvitedEventListSorted = userInvitedEventList.sorted(by: {$0.timeStamp > $1.timeStamp})
                        print("userInvitedEventList: \(userInvitedEventList)")
                        print("userInvitedEventListSorted: \(userInvitedEventListSorted)")
                        
                    }}
                
                self.userInvitedEvents.reloadData()
            }}}

    
    //    Mark: Tableview setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows = 1
        
//        numberOfRows = userInvitedEventListSorted.count
        
        print("number of rows in userinvited event table \(numberOfRows)")
        
        return numberOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSections = userInvitedEventListSorted.count
        
        if numberOfSections == 0{
            numberOfSections = 1
            print("numberOfSections 1: \(numberOfSections)")
            
        }
        else{
            print("numberOfSections: \(numberOfSections)")
            
        }
        
        
        return numberOfSections
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item: eventSearch
        
        guard let cell = userInvitedEvents.dequeueReusableCell(withIdentifier: "userInvitedCell", for: indexPath) as? UserInvitedEventsCell
            else{
                fatalError("could not create user invited cell")
        }
        
        if userInvitedEventListSorted.count == 0{
            
            cell.userInvitedCellLabel1.text = "You haven't been invted to any events"
            cell.userInvitedCellLabel2.text = "Head to 'Create An Event' to get started"
            
            
            cell.userInvitedCellLabel1.adjustsFontSizeToFitWidth = true
            cell.userInvitedCellLabel2.adjustsFontSizeToFitWidth = true
            cell.userInvitedCellLabel3.text = ""
            
        }
        else{
        
        
        
        item = userInvitedEventListSorted[indexPath.section]
        let eventTitleDescription = NSMutableAttributedString(string: item.eventDescription,
                                                              attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        eventTitleDescription.append(NSMutableAttributedString(string: " \(item.eventOwnerName)",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]))
        
        cell.userInvitedCellLabel1.attributedText = eventTitleDescription
        cell.userInvitedCellLabel2.text = ("Location: \(item.eventLocation) \nTime: \(item.eventStartTime) - \(item.eventEndTime)")
        cell.userInvitedCellLabel3.text = ("Time: \(item.eventStartTime) - \(item.eventEndTime)")
            
        cell.userInvitedCellLabel1.adjustsFontSizeToFitWidth = true
        cell.userInvitedCellLabel2.adjustsFontSizeToFitWidth = true
        cell.userInvitedCellLabel3.adjustsFontSizeToFitWidth = true
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
            
        }

        return cell
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
        
        selectEventToggle = 0
        let info = userInvitedEventListSorted[indexPath.section]
        print(info)
        eventIDChosen = info.eventID
        
        //        gets all the event details neededd to create the event detail arrays
        addDatesToResultQuery2(eventID: eventIDChosen, selectEventToggle: 0){ (arrayForEventResultsPage, arrayForEventResultsPageDetails, numberOfDatesInArray)  in
            
            
            
            let noResultsArray = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).noResultsArray
            let nonUserArray = self.noResultArrayCompletion2(numberOfDatesInArray: numberOfDatesInArray).nonUserArray
            
            self.addUserToEventArray2(eventID: eventIDChosen, noResultArray: noResultsArray){ (arrayForEventResultsPageAvailability) in
                
                self.addNonExistentUsers(eventID: eventIDChosen, noResultArray: nonUserArray){ (addNonExistentUsersAvailability, nonExistentNames) in
                    
                    eventResultsArrayDetails = arrayForEventResultsPageDetails + [nonExistentNames]
                    print("eventResultsArrayDetails \(eventResultsArrayDetails)")
                    
                    let resultsSummary = self.resultsSummary(resultsArray: arrayForEventResultsPage + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability).countedResults
                    
                    availabilitySummaryArray = resultsSummary
                    
                    print("resultsSummaryArray: \(resultsSummary)")
                    
                    
                    arrayForEventResultsPageFinal = arrayForEventResultsPage + resultsSummary + arrayForEventResultsPageAvailability + addNonExistentUsersAvailability
                    print("arrayForEventResultsPageFinal \(arrayForEventResultsPageFinal)")
                
                    self.userInvitedEvents.deselectRow(at: indexPath, animated: true)
                    
                self.performSegue(withIdentifier: "eventResultsInvited", sender: self)
                
                
                
                
            }
            }
            
        }
        
    }
    


}
