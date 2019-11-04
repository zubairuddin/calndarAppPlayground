//
//  CreateEventViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import DLRadioButton
import MBProgressHUD
import Firebase
import EventKit
import AMPopTip
import Alamofire
import Fabric
import Crashlytics

//Gloabl variables available to any viewController
//Zubair: As I said earlier, use a global manager class for all the firebase related stuff
var settings = dbStore.settings
var dbStore = Firestore.firestore()
var userEventList = [eventSearch]()
var userEventListSorted = [eventSearch]()
var userInvitedEventList = [eventSearch]()
var userInvitedEventListSorted = [eventSearch]()
var anyArray = [[Any]]()
var eventResultsArrayDetails = [[Any]]()
var notExistingUserArray = [String]()
var selectEventToggle = 1
var daysOfTheWeek = [Int]()
var daysOfTheWeekNewEvent = [Int]()
var user = Auth.auth().currentUser?.uid
var calendars: [EKCalendar]?
var eventStore = EKEventStore()
var calendarArray = [EKEvent]()
var calendarEventArray : [Event] = [Event]()
var numberOfItems = 1
var selectedContactNames = [String]()
var datesToChooseFrom = Array<Any>()
var appTitle = "CircleIT"
var countedResultArrayFraction = [Float]()
var currentUserAvailabilityDocID = String()

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}


//Zubair: I would suggest conforming using extensions just for better readablity and to be more swifty.
class CreateEventViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {

//    variables for setting menu items and segues
    //Zubair: Please use constants
    var menuLabels = [["Create An Event"," Your Events"],["Friends Events","Friend Circles (coming soon)"],["Upload A Photo (coming soon)",""]]
    var pictureNames = [["PlusCircleCloud","Person"],["Meeting","People"],["Camera",""]]
//    var pictureNames = [["RP - Calendar","RP - Your events"],["Meeting","RP - Friends Circle"],["RP - Upload a Photo",""]]
    var segueIdentifiers = [["createEventSegue","viewYourCreatedEventsSegue"],["userInvitedEventsSegue",""],["",""]]
    
//    date format variables
    var dateFormatterForResultsCreateEvent = DateFormatter()
    var dateFormatterTime = DateFormatter()
    var dateFormatterSimple = DateFormatter()
    var dateFormatterTZ = DateFormatter()
    
//    other variables
    var newEventID = String()
    var startDate = Date()
    var endDate = Date()
    var startDateEnd = Date()
    var startEndDate = Date()
    var datesBetweenChosenDatesStart = Array<Date>()
    var datesBetweenChosenDatesEnd = Array<Date>()
    var datesOfTheEvents = Array<Date>()
    var startDatesOfTheEvents = Array<Date>()
    var endDatesOfTheEvents = Array<Date>()
    var finalAvailabilityArray = Array<Int>()
    var userEventStoreID = String()
    var fireStoreRef: DatabaseReference!
    
    
    //        create Circleit title
    
    
   //Zubair: Use proper initials for IBOutlets
    @IBOutlet var collectionViewMenu: UICollectionView!
    
    @IBOutlet weak var testTheCodeButton: UIButton!
    
    
    @IBOutlet weak var introText: UILabel!
    
    @IBAction func testTheCode(_ sender: UIButton) {
        

        assert(false)
        Crashlytics.sharedInstance().crash()
        
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Zubair: viewDidLoad() contains around 300 lines here which is too much. It should only contain basic setup code and calls to some functions when the view loads.
//      check that the user is in our user database, or log them out
        
        checkUserInUserDatabase()
        
        
        checkCalendarStatus2()

        
//        setup the navigation controller Cirleit text
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: "Circle",
                                                              attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        navTitle.append(NSMutableAttributedString(string: "it",
                                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        navLabel.attributedText = navTitle
        
        navigationItem.titleView = navLabel
        

        //Zubair: If this is used at multiple places, why not use extensions for this
        let welcomeText = NSMutableAttributedString(string: "Welcome to Circle",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        welcomeText.append(NSMutableAttributedString(string: "it",
                                                    attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        welcomeText.append(NSMutableAttributedString(string: "! \n\nThe mobile app that revolutionises organising time with friends. Create an Event, invite your friends and we'll do the rest.",
        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        introText.attributedText = welcomeText
        

        
//        navigationController?.navigationBar.barTintColor = UIColor(patternImage: UIImage(named: "blue-background-bricks-close-up-2096622")!)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)

        navigationController?.navigationBar.tintColor = UIColor.black
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: ""), for: UIBarMetrics.default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
        
//        Hides the navigation bar back button on the page
        
        navigationItem.hidesBackButton = true
        
//        hide code test button
        testTheCodeButton.isHidden = true
        
        
//        Fabric debugging mode
//        Fabric.sharedSDK().debug = true
        
//        view settings

        view.backgroundColor = UIColor.white
        
        collectionViewMenu.backgroundColor = UIColor.white
        
//        get users push notification token
        registerForPushNotifications()
        
//        setup for the collectionview
        collectionViewMenu.delegate = self
        collectionViewMenu.dataSource = self
        
//        date formats
        
        //Zubair: Please try to use functions as much as possible
        dateFormatterForResultsCreateEvent.dateFormat = "E d MMM HH:mm"
        dateFormatterForResultsCreateEvent.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
        summaryView = false
        
//        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait

        
        //        Mark: Firebase listeners
        //        listener to detect when any events are added with the users username in them
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global()
        
        //Zubair: Don't write firebase code here, use a manager class.
        var newEventListener = dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            queue.async {
            
        
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New event: \(diff.document.data())")
                    
                    let source = diff.document.metadata.hasPendingWrites ? "Local" : "Server"
                    
//                    To check whether availability has already been supplied
                    let userAvailabilityCheck = diff.document.get("userAvailability") as? [Int] ?? [99]
                    print("userAvailabilityCheck: \(userAvailabilityCheck)")
                    
                    
//                    if availability exist then stop the process
                    if source == "local" || userAvailabilityCheck[0] != 99 {
                        
                        //                        for local updates we do nothing
                        
                    }
                    else{
      
                        self.checkCalendarStatus2()
                        self.newEventID = diff.document.get("eventID") as! String
                        self.userEventStoreID = diff.document.documentID

                        self.getEventInformation3(eventID: self.newEventID, userEventStoreID: self.userEventStoreID) { (userEventStoreID, eventSecondsFromGMT, startDates, endDates) in
                            
                            print("Succes getting the event data")
                            
                            print("startDates: \(startDates), endDates: \(endDates)")
                            
                            
                            let numberOfDates = endDates.count - 1
                            
                            let startDateDate = self.dateFormatterTZ.date(from: startDates[0])
                            let endDateDate = self.dateFormatterTZ.date(from: endDates[numberOfDates])

                            let endDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).endDatesOfTheEvents
                            let startDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).startDatesOfTheEvents
                                
                            
                            
                            let finalAvailabilityArray2 = self.compareTheEventTimmings3(datesBetweenChosenDatesStart: startDates, datesBetweenChosenDatesEnd: endDates, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
                            
                            
                            //                        add the finalAvailabilityArray to the userEventStore
                            
                            
                            self.commitUserAvailbilityData(userEventStoreID: userEventStoreID, finalAvailabilityArray2: finalAvailabilityArray2)
                                semaphore.signal()
                            }
                       semaphore.wait()
                    }
                    
                    
                    
                }
                
                if (diff.type == .modified) {
                    print("Modified event: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removed event: \(diff.document.data())")
                }
                
                }
                
            }
            
        }
        
        
        //Zubair: Don't write firebase code here. As I said earlier, use a global manager class for this.
       var dateChosenListener = dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    
                    if diff.document.get("chosenDate") == nil {
                        
                        print("no date chosen")
                        
                    }
                    else{
                        
                        //            the default for a firebase listener is to react to both the local write and the cloud stored event, hence we isolate the cloud event only to ensure we only add the event to the calendar once
                        let source = diff.document.metadata.hasPendingWrites ? "Local" : "Server"
                        //            print("\(source) data: \(diff.document.data() )")
                        
                        //            we set nothing to happen if the source is the local write
                        if source == "local" {
                            
                        }
                        else{
                            
                            //            print("date chosen: \(diff.document.get("chosenDate") ?? "date chosen did not unwrap")")
                            let eventID = diff.document.get("eventID")
                            print("date chosen listener eventID \(String(describing: eventID))")
                            //Zubair: Try to avoid force unwrapping whenever possible. Use guard let or if let to unwrap optionals
                            let chosenDateCreate = diff.document.get("chosenDate") as! String
                            print("date chosen listener chosen date \(chosenDateCreate)")
                            dbStore.collection("eventRequests").document(eventID as! String).getDocument(completion: { (documentEventData, error) in
                                if error != nil {
                                    print("Error getting documents for adding event")
                                }
                                else{
                                    
                                    var checkForData = documentEventData!.get("startTimeInput") as? String ?? ""
                                    
                                    if checkForData == "" {
                                        
                                        print("This event was deleted - we do not continue")
                                        
                                    }
                                    else{
                                        
                                        print(documentEventData!)
                                    
                                        //Zubair: Try avoiding force unwrapping of optionals
                                    let startTimeString = documentEventData!.get("startTimeInput") as! String
                                        
                                    let allStartDates = documentEventData!.get("startDates") as! [String]
                                        
                                        
                                        let allEndDates = documentEventData!.get("endDates") as! [String]
                                        
                                        let dateFormatterTZCreate = DateFormatter()
                                        dateFormatterTZCreate.dateFormat = "yyyy-MM-dd HH:mm z"
                                        dateFormatterTZCreate.locale = Locale(identifier: "en_US_POSIX")
                                        
                                        
                                        
                                    let chosenDatePosition = documentEventData!.get("chosenDatePosition") as! Int
                                        
                                        let chosenStartDate = allStartDates[chosenDatePosition]
                                        print("chosenStartDate \(chosenStartDate)")
                                        
                                        let chosenEndDate = allEndDates[chosenDatePosition]
                                        print("chosenEndDate: \(chosenEndDate)")
                                        
                                        let starDateDisplay = documentEventData!.get("chosenDate") as? String ?? ""
//
//                                        let chosenStartDateDate = dateFormatterTZCreate.date(from:chosenStartDate)
//                                        print("chosenStartDateDate: \(String(describing: chosenStartDateDate))")
//                                        let chosenEndDateDate = dateFormatterTZCreate.date(from:chosenEndDate)
//                                        print("chosenEndDateDate: \(String(describing: chosenEndDateDate))")
                                    
                                    let eventCreatorCreate = documentEventData!.get("eventOwnerName") as? String ?? ""
                                    
                                    let eventLocationCreate = documentEventData!.get("location") as? String ?? ""
                                    //                    print(eventLocationCreate)
                                    let eventDescriptionCreate = documentEventData!.get("eventDescription") as? String ?? ""
                           
                                    
                                    //                    Adds the event to the users calendar
                                        self.addEventToCalendar(title: eventDescriptionCreate, description: eventDescriptionCreate, startDate:  chosenStartDate, endDate: chosenEndDate, location: eventLocationCreate, eventOwner: eventCreatorCreate, startDateDisplay: starDateDisplay)
                                    
                                    }
                                    
                                }})
                                
                            }
                        
                    }
                    
                }

            }

            //        Mark: end of viewDidLoad

        
        }
        
    //Zubair: This should be outside of viewDidLoad
    func viewWillDisappear(_ animated: Bool) {
            
            newEventListener.remove()
//            dateChosenListener.remove()
        
            
        }
    }

    
    //    MARK: CollectionView Setup
    
    //Zubair: If delegate and datasource methods are written within extensions, it's better for readability
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let noSections = 2
        
        return noSections
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let noRows = 3
        
        return noRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "firstMenuCell", for: indexPath) as? FirstMenuCollectionViewCell
            else{
                fatalError("Issue displaying the collectionview cell")
        }
        
        
        //Zubair: Cell formatting code should be within your custom cell class and not within cellForRowAtIndexPath. This method gets called multiple times, if we use formatting code within this, it would have an impact on performance
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        
//        cell.backgroundColor = UIColor(patternImage: UIImage(named: "19292.jpg")!)
        
//        cell.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
//        cell.backgroundColor = UIColor(red: 50, green: 139, blue: 168)
        cell.backgroundColor = UIColor.white
        cell.menuImage.image =  UIImage(named: pictureNames[indexPath.section][indexPath.row])
        
        cell.menuLabel.text = menuLabels[indexPath.section][indexPath.row]
        
        cell.menuLabel.lineBreakMode = .byWordWrapping
        cell.menuLabel.numberOfLines = 2
        cell.menuLabel.font = UIFont.systemFont(ofSize: 15)
        
//        cell.layer.borderColor = borderColour.cgColor
        
        return cell
 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        do something when a cell is selected
        print("selected cell \(indexPath.section)\(indexPath.row)")
        
//        remove any selected contacts from the array
        contactsSelected.removeAll()
        
        if segueIdentifiers[indexPath.section][indexPath.row] == ""{
         
            print("Segue doesnt exist")
            
        }
        else{
        performSegue(withIdentifier: segueIdentifiers[indexPath.section][indexPath.row], sender: Any.self)
        }
        
    }
    
    //        Requests permission to send push notifications to the user
    //Zubair: I believe you can write the code to register for push notifications in AppDelegate
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
                self?.getUserPushToken()

        }}
    
    //    Returns the user notification settings the user gave us access to
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    //    called when the registration for push notifications succeeds
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    //    called when the registration for push notifications fails
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    
    func getUserPushToken(){
    InstanceID.instanceID().instanceID { (result, error) in
    if let error = error {
    print("Error fetching remote instance ID: \(error)")
    } else if let result = result {
    print("Remote instance ID token: \(result.token)")
    
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            
            print("querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("there was an error")
            }
            else {
                for document in querySnapshot!.documents {
                 
                    let documentID = document.documentID
                    let name = UserDefaults.standard.value(forKey: "name")
                    // Reference for the realtime database
                    let ref = Database.database().reference()
                    
                    dbStore.collection("users").document(documentID).setData(["tokenID" : result.token], merge: true)
                    
                    ref.child("users/\(user!)/\(result.token)").setValue(result.token)
                    ref.child("users/\(user!)/name").setValue(name)

                    
                }
                
                
            }
        
    }
    }
    }

   
}
}





// Mark: Code - used to house all the global functions within the App

//Zubair: Create a separate class rather than writing global functions within UIViewController itself
extension UIViewController {
    
    
    //    Function: converts the input string into a date and converts to local timezone. Input: String, Output: String
    func convertToLocalTime(inputTime: String) -> String{
        
        print("running func convertToLocalTime inputs - inputTime: \(inputTime)")
        
        var timeInLocal = String()
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")

        let dateStartDate = dateFormatterTime.date(from: inputTime)
        let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(secondsFromGMT))
        let adjStartTimeString = dateFormatterTime.string(from: adjStartTimeDate)
        
        timeInLocal = adjStartTimeString
        print("timeInLocal \(timeInLocal)")
        
       return timeInLocal
    }
    
    
    //    Function: converts the input string into a date and converts to GMT. Input: String, Output: String
    func convertToGMT(inputTime: String) -> String{
        
        print("running func convertToGMT inputs - inputTime: \(inputTime)")
        
        var timeInGMT = String()
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        
        let dateStartDate = dateFormatterTime.date(from: inputTime)
        let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
        let adjStartTimeString = dateFormatterTime.string(from: adjStartTimeDate)
        
        timeInGMT = adjStartTimeString
        print("timeInGMT \(timeInGMT)")
        
        return timeInGMT
    }
    
    
    //    Function: converts the input string into a date and converts to the display format for dates in the app
    func convertToDisplayDate(inputDate: String) -> String{
        
        print("running func convertToDisplayDate inputs - inputDate: \(inputDate)")
        
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM YYYY"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        
        let dateDate = dateFormatterStringDate.date(from: inputDate)

        let dateString = dateFormatterDisplayDate.string(from: dateDate!)
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    

    
    //    Function: converts the input string into a date and converts to the database storage format for dates in the app
    func convertToStringDate(inputDate: String) -> String{
        
        print("running func convertToDisplayDate inputs - inputDate: \(inputDate)")
        
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM yyyy"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        print("inputDate: \(inputDate)")
        
        let dateDate = dateFormatterDisplayDate.date(from: inputDate)
        print("dateDate: \(String(describing: dateDate))")
        
        let dateString = dateFormatterStringDate.string(from: dateDate!)
        print("dateString: \(dateString)")
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    
    func convertToStringDateDisplay(inputDate: String) -> String{
        
        print("running func convertToDisplayDate inputs - inputDate: \(inputDate)")
        
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM yyyy"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        print("inputDate: \(inputDate)")
        
        let dateDate = dateFormatterStringDate.date(from: inputDate)
        print("dateDate: \(String(describing: dateDate))")
        
        let dateString = dateFormatterDisplayDate.string(from: dateDate!)
        print("dateString: \(dateString)")
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    
    func convertLongDateToDisplayDate(inputDate: String) -> String{
        var displayDate = String()
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM YYYY"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterStringDate = DateFormatter()
        dateFormatterStringDate.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterStringDate.locale = Locale(identifier: "en_US_POSIX")
        
        let dateDate = dateFormatterStringDate.date(from: inputDate)
        
        let dateString = dateFormatterDisplayDate.string(from: dateDate!)
        
        displayDate = dateString
        print("displayDate \(displayDate)")
        
        return displayDate
    }
    
    
//    function to allow for the process of a string array into the phone number cleaning function
    
    func getSelectedContactsPhoneNumbers2() -> (phoneNumbers:[String], names:[String]){
        
        print("running func getSelectedContactsPhoneNumbers2")
        
        selectedContacts.removeAll()
        selectedContactNames.removeAll()
        
        print("contactsSelected: \(contactsSelected)")

            for contact in contactsSelected{
                if contact.selectedContact == true {
                    
                   let cleanPhoneNumber = cleanPhoneNumbers(phoneNumbers: contact.phoneNumber)
                    let contactName = contact.name
                    
                        selectedContacts.append(cleanPhoneNumber)
                        selectedContactNames.append(contactName)
   
                }}
        print("output: phoneNumbers: \(selectedContacts) names: \(selectedContactNames)")
        return (phoneNumbers: selectedContacts, names: selectedContactNames)
        }
    
    
    func createUserIDArrays(phoneNumbers: [String], names: [String], completionHandler: @escaping (_ nonExistentArray: [String], _ existentArray: [String], _ existentNameArray: [String], _ nonExistentNameArray: [String]) -> ()){
        
        var nonExistentArray = [String]()
        var existentArray = [String]()
        var existentNameArray = [String]()
        var nonExistentNameArray = [String]()
        var n = 0
        let phoneNumbersCount = phoneNumbers.count
        
        print("running func createUserIDArrays, inputs - phoneNumbers: \(phoneNumbers) names: \(names)")

        for numbers in phoneNumbers{
        
            getUserID(phoneNumber: numbers) { (userID, userExists, userName) in
  
            if userExists == false{
                n = n + 1
                
                let indexOfItem = phoneNumbers.index(of: numbers)
                print("indexOfItem: \(String(describing: indexOfItem))")
                
              nonExistentArray.append(numbers)
                nonExistentNameArray.append(names[indexOfItem!])
                
                if n == phoneNumbersCount{
                    print("nonExistentArray: \(nonExistentArray), existentArray: \(existentArray), existentNameArray: \(existentNameArray), nonExistentNameArray: \(nonExistentNameArray)")
                    completionHandler(nonExistentArray, existentArray, existentNameArray, nonExistentNameArray)
                    
                }
            
            }
            else{
                n = n + 1
                
                existentArray.append(userID)
                existentNameArray.append(userName)
                
                if n == phoneNumbersCount{
                    print("nonExistentArray: \(nonExistentArray), existentArray: \(existentArray), existentNameArray: \(existentNameArray), nonExistentNameArray: \(nonExistentNameArray)")
                    completionHandler(nonExistentArray, existentArray, existentNameArray, nonExistentNameArray)
                    
                }
                
            }
                
                
            }
            
            }
        
        
    }
    
//    (_ userID: String,_ userExists: Bool,_ userName: String)
    
    func getUserID(phoneNumber: String, completionHandler: @escaping (_ userID: String, _ userExists: Bool, _ userName: String) -> ()){
    
        var userExists = Bool()
        var userID = String()
        var userName = String()
        
        
        //Zubair: Use the global firebase class
        dbStore.collection("users").whereField("phoneNumbers", arrayContains: phoneNumber).getDocuments { (querySnapshot, error) in
            
            print("querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("there was an error")
            }
            else {
                print("querySnapshot!.isEmpty: \(querySnapshot!.isEmpty)")
                
                if querySnapshot!.isEmpty{
                    
                    print("The phone number is not in the Circles DB")
                    
                    userExists = false
                    userID = ""
                    completionHandler(userID, userExists, userName)
                    
                }
                else{
                    for document in querySnapshot!.documents {
                        print("document information: \(document.documentID) => \(document.data())")
                        
                        userExists = true
                        
                        let myAddedUserID = document.get("uid") as! String
                        let myAddedUserName = document.get("name") as! String
                        print("Next user to be added to the userIDArray \(myAddedUserID)")
                        userID = myAddedUserID
                        userName = myAddedUserName
                        completionHandler(userID, userExists, userName)
                    }}
            }
            
        }
   
    }
    
    
    func addNonExistingUsers2(phoneNumbers: [String], eventID: String, names: [String]){
        
        var nameToUpload = String()
        
        print("running func addNonExistingUsers2, inputs - phoneNumbers: \(phoneNumbers) eventID: \(eventID) names: \(names)")
        
        for phoneNumber in phoneNumbers{
            
            let indexOfItem = phoneNumbers.index(of: phoneNumber)
            
            print("indexOfItem: \(String(describing: indexOfItem))")
            print("current phone number: \(phoneNumber)")
            print("current name: \(names[indexOfItem!])")
            
//            Check to esnure a users name is always uploaded
            if names[indexOfItem!] == ""{
              
                nameToUpload = "Unknown Name"
                
            }
            else{
                nameToUpload = names[indexOfItem!]
            }
        
            //Zubair: Use the global Firebase Manager class
            dbStore.collection("temporaryUserEventStore").addDocument(data: ["eventID": eventID, "phoneNumber": phoneNumber, "name": nameToUpload])
            
        }
        
    }
    
    
//    adds the user and eventID into the userEventStore
    func userEventLinkArray( userID: [String], userName: [String], eventID: String){
        
        print("running func userEventLinkArray, inputs - userID: \(userID) userName: \(userName) eventID: \(eventID)")
        
        let ref = Database.database().reference()
        let numberOfUsers = userID.count
        print("numberOfUsers: \(numberOfUsers)")
        var n = 0
        
        while n <= numberOfUsers - 1{
        
            //Zubair: Use the global Firebase Manager class
        dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": userID[n], "userName": userName[n]])
            
//            adds the username to the real time database
            ref.child("userEventLink/\(userID[n])/\(eventID)").setValue(eventID)
        
            n = n + 1
            
        }

        
    }
    
    
//    deletes the user and eventId from the userEventStore
    func deleteUserEventLinkArray(userID: [String], eventID: String){
        
        print("running func deleteuserEventLinkArray - inputs userID: \(userID) eventID: \(eventID)")
        
      for users in userID{
        print("users: \(users)")

        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("uid", isEqualTo: users).getDocuments() { (querySnapshot, err) in
            
            print("querySnapshot: \(String(describing: querySnapshot))")
            print("is querySnapshot empty \(String(describing: querySnapshot?.isEmpty))")
            
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    print("documentID: \(documentID)")
                    
                    docRefUserEventStore.document(documentID).delete()
                    
                    docRefUserEventStore.document(documentID).updateData(["userAvailability" : FieldValue.delete()]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
//                    docRefUserEventStore.document(documentID).delete()
                }
                
            }
            
        }
        
        }
   
    }
    
    

    //    get the current users phone number
    func getCurrentUsersPhoneNumber2() -> [String]{
        
        print("running func getCurrentUsersPhoneNumber2")
        
        var usersPhoneNumber = String()
        //Zubair: Use the global Firebase Manager class
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments{ (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents{
                    usersPhoneNumber = document.get("phoneNumber") as! String
                    print("Current users phone number to add to selected contacts \(String(describing: usersPhoneNumber))")
                }
  
            }
        }
        print("[usersPhoneNumber]: \([usersPhoneNumber])")
        return [usersPhoneNumber]
    }
    
//    add user IDs to the eventRequests table
    
    func addUserIDsToEventRequests(userIDs: [String], currentUserID: [String],existingUserIDs: [String], eventID: String, addCurrentUser: Bool) {
        
        var allUsers = [String]()
        
        print("running func addUserIDsToEventRequests, inputs - userID: \(userIDs) currentUserID: \(currentUserID) existingUserIDs: \(existingUserIDs) eventID: \(eventID) addCurrentUser: \(addCurrentUser)")
        
        if addCurrentUser == true{
            
            allUsers = userIDs + currentUserID + existingUserIDs
            
            dbStore.collection("eventRequests").document(eventID).setData(["users" : allUsers], merge: true)
            
        }
        else{
        
        allUsers = userIDs + existingUserIDs
            dbStore.collection("eventRequests").document(eventID).setData(["users" : allUsers], merge: true)
            
        }
   
    }
    
//function returns a clean phone number fron the dirty phone number used as an input
func cleanPhoneNumbers(phoneNumbers: String) -> String{
    
    print("running func cleanPhoneNumbers: Input PhoneNumbers: \(phoneNumbers)")
        
        let currentLocale = NSLocale.current.regionCode
        let countryPrefix = countryCodePrefixes.countryCodes[currentLocale!]!
        let phoneNumberLen = phoneNumbers.count
        
        //        print(countryPrefix)
        //        print(currentLocale!)
        
        var returnedPhoneNumber = String()
        
        //            used to remove all the non digit characters within the phone numbers
        let phoneNumberClean = phoneNumbers.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
        
        
        
        //        If the phone number starts with a + we assume it is in the correct format
    
    if phoneNumberLen > 10 && phoneNumbers[0] == "+" {
        let phoneNumberLenClean = phoneNumberClean.count
        let phoneNumberZero = phoneNumberLenClean - 11
        let numberZero = phoneNumberClean[phoneNumberZero]
        
        if numberZero == "0"{
            
            let phoneNumberZero = phoneNumberLenClean - 11
            let phoneNumberZeroSecond = phoneNumberLenClean - 10
            
            let firstPart = phoneNumberClean[..<phoneNumberZero]
            print("firstPart: \(firstPart)")
            let secondPart = phoneNumberClean[phoneNumberZeroSecond...]
            print("secondPart: \(secondPart)")
            
            print("combined: \(firstPart)\(secondPart)")
            
            returnedPhoneNumber = "+\(firstPart)\(secondPart)"
        }
        else{
            returnedPhoneNumber = "+\(phoneNumberClean)"
            
        }
        
        
    }
            
        else if phoneNumberClean.count == 10{
            returnedPhoneNumber = "+\(countryPrefix)\(phoneNumberClean)"
            
        }
            
        else if phoneNumberClean.count == 11 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(countryPrefix)\(phoneNumberClean.dropFirst(1))"
        }
            
        else if phoneNumberClean.count == 11 {
            
            //                remove the first character
            returnedPhoneNumber = "+\(phoneNumberClean)"
        }
        else if phoneNumberClean.count == 12 && phoneNumberClean[0] == "0" && phoneNumberClean[1] == "0"{
            
            //                remove the first character
            
            returnedPhoneNumber = "+\(countryPrefix)\(phoneNumberClean.dropFirst(1))"
        }
        else if phoneNumberClean.count == 12 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(1))"
        }
        else if phoneNumberClean.count == 13 && phoneNumberClean[0] == "0" && phoneNumberClean[1] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(2))"
        }
        else if phoneNumberClean.count == 13 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(1))"
        }
        else if phoneNumberClean.count == 14 && phoneNumberClean[0] == "0" && phoneNumberClean[1] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(2))"
        }
        else if phoneNumberClean.count == 14 && phoneNumberClean[0] == "0"{
            
            returnedPhoneNumber = "+\(phoneNumberClean.dropFirst(1))"
        }
        else{
            returnedPhoneNumber = phoneNumberClean
        }
        
        print("returnedPhoneNumber \(returnedPhoneNumber)")
        return returnedPhoneNumber
    }
    
    
    func sendInviteTextMessages(notExistingUserArray: [String]){
        print("sendTextMessages Initiated")
        
        //            dummy numbers for testing, comment out when commiting
        //        let notExistingUserArray = ["+15557664823","+1888555512"]
        
        for phoneNumbers in notExistingUserArray{
            
            let parameters = ["From": "+17372105712", "To": phoneNumbers, "Body": "Hello from the Circleit Team! Your friend XX invited you to sign-up, click the link below to download the App and join the Circleit revolution"]
            
//            Alamofire.request(twilioLogIn.url, method: .post, parameters: parameters)
//                .authenticate(user: twilioLogIn.accountSID, password: twilioLogIn.authToken)
//                .responseString { response in
//                    debugPrint(response)
//
//            }
            
        }
        
    }
    
    

    
    func dateChosenAlert(){
        
        print("running func dateChosenAlert")
        
        let alertEventComplete = UIAlertController(title: "Congratualtions! Your event has been finalised", message: "You invitees will be sent a message notifying them of the date", preferredStyle: UIAlertController.Style.alert)
        
        alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            print("User Selected OK on event creation alert")
            
            self.performSegue(withIdentifier: "dateChosenSave", sender: self)

            
        }))
        self.present(alertEventComplete, animated: true, completion: {
    
        
        
        })
        
    }
    
    
//  Code to create the array we send to the event results page
    func addDatesToResultQuery2( eventID: String, selectEventToggle: Int, completion: @escaping (_ arrayForEventResultsPage: [[Any]], _ arrayForEventResultsPageDetails: [[Any]], _ numberOfDatesInArray: Int) -> Void) -> (){
        
        
        print("running func addDatesToResultQuery2 inputs - eventID: \(eventID) selectEventToggle: \(selectEventToggle)")
        
        //        add the top row of dates and a single blank
        //        arrayForEventResultsPage
        
        var arrayForEventResultsPage = [[Any]]()
        var arrayForEventResultsPageDetails = [[Any]]()
        var emptyArray = Array<Any>()
        var emptyArray3 = Array<Any>()
        var emptyArray6 = Array<Any>()
        var emptyArray7 = Array<Any>()
        var emptyArray8 = Array<Any>()
        var emptyArray9 = Array<Any>()
        var emptyArray10 = Array<Any>()
        var emptyArray11 = Array<Any>()
        var emptyArray12 = Array<Any>()
        var emptyArray13 = Array<Any>()
        var emptyArray14 = Array<Any>()
        var startDate = Date()
        var endDate = Date()
        let dateFormatter = DateFormatter()
        let dateFormatterForResults = DateFormatter()
        let dateFormatterSimple = DateFormatter()
        var numberOfDatesInArray = Int()
        let dateFormatterTz = DateFormatter()

        
        
        emptyArray.removeAll()
        emptyArray3.removeAll()
        emptyArray6.removeAll()
        emptyArray7.removeAll()
        emptyArray8.removeAll()
        datesToChooseFrom.removeAll()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterForResults.dateFormat = "E d MMM"
        dateFormatterTz.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterForResults.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTz.locale = Locale(identifier: "en_US_POSIX")
        
        let docRefEventRequest = dbStore.collection("eventRequests").document(eventID)
        docRefEventRequest.getDocument { (document, error) in
            if let document = document, document.exists {
                
//                get the start and end time of the event
                let startTimeString = document.get("startTimeInput") as! String
                let endTimeString = document.get("endTimeInput") as! String
                
                let startDateInputResult = document.get("startDateInput") as! String
                let eventDescriptionInputResult = document.get("eventDescription") as! String
                let eventLocationInputResult = document.get("location") as! String
                let startTimeInputResult = self.convertToLocalTime(inputTime: startTimeString)
                let endDateInputResult = document.get("endDateInput") as! String
                let dateChosenInput = document.get("chosenDate") ?? ""
                let endTimeInputResult = self.convertToLocalTime(inputTime: endTimeString)
                let documentIDResult = document.documentID
                let invitees = document.get("users")  as! Array<String>
                daysOfTheWeek = document.get("daysOfTheWeek") as! [Int]
                startDate = dateFormatter.date(from: startDateInputResult + " " + startTimeInputResult)!
                print(startDate)
                endDate = dateFormatter.date(from: endDateInputResult + " " + endTimeInputResult)!
                print(endDate)
                
//                get the dates between the start and end date
                self.getArrayOfChosenDates3(eventID: eventID, completion: { (startDates, endDates) in
                    

                
                for dates in startDates {
 
//                    converting the dates to test back to the string and format we want to display
                    let newDate = dateFormatterTz.date(from: dates)
                    
                    emptyArray.append(dateFormatterForResults.string(from: newDate!))
//                    adds all other event information into arrays for adding to the details array later
                    emptyArray3.append(dateFormatterSimple.string(from: newDate!))
                    emptyArray6.append(eventLocationInputResult)
                    emptyArray7.append(eventDescriptionInputResult)
                    emptyArray8.append(documentIDResult)
                    emptyArray9.append(startDateInputResult)
                    emptyArray10.append(endDateInputResult)
                    emptyArray11.append(startTimeString)
                    emptyArray12.append(endTimeString)
                    emptyArray13.append(invitees)
                    emptyArray14.append(daysOfTheWeek)
                }
                var x = emptyArray
                x.insert(dateChosenInput, at: 0)
                datesToChooseFrom = x
                print("datesToChooseFrom: \(datesToChooseFrom)")
                emptyArray.insert("", at: 0)
                emptyArray3.insert("", at: 0)
                emptyArray6.insert("", at: 0)
                emptyArray7.insert("", at: 0)
                emptyArray8.insert("", at: 0)
                //                adds the date and select text to the top of the results array
                arrayForEventResultsPage.append(emptyArray)
                print("arrayForEventResultsPage: \(arrayForEventResultsPage)")
                //                creates second array with details of the event
                arrayForEventResultsPageDetails.append(emptyArray3)
                arrayForEventResultsPageDetails.append(emptyArray6)
                arrayForEventResultsPageDetails.append(emptyArray7)
                arrayForEventResultsPageDetails.append(emptyArray8)
                arrayForEventResultsPageDetails.append(emptyArray9)
                arrayForEventResultsPageDetails.append(emptyArray10)
                arrayForEventResultsPageDetails.append(emptyArray11)
                arrayForEventResultsPageDetails.append(emptyArray12)
                arrayForEventResultsPageDetails.append(emptyArray13)
                arrayForEventResultsPageDetails.append(emptyArray14)
                print("arrayForEventResultsPageDetails: \(arrayForEventResultsPageDetails)")
                numberOfDatesInArray = emptyArray.count
                completion(arrayForEventResultsPage, arrayForEventResultsPageDetails, numberOfDatesInArray)
                
                    })
            }
        }
        
    }
    
    
//    creates an array of both 10 and 11 for use in the user availability arrays, this denotes the not responded and those who have not signed up as users
    func noResultArrayCompletion2(numberOfDatesInArray: Int) -> (noResultsArray: [Int],nonUserArray: [Int]){
    
       print("running func getDayOfWeek2 inputs - numberOfDatesInArray: \(numberOfDatesInArray)")
        
        var noResultsArray = [Int]()
        var nonUserArray = [Int]()
        var n = 0
        let y = 10
        let x = 11
        
        
        while n <= numberOfDatesInArray - 2 {
            
            noResultsArray.append(y)
            nonUserArray.append(x)
            n = n + 1
        }
        print("noResultsArray \(noResultsArray) nonUserArray \(nonUserArray)")
        return (noResultsArray: noResultsArray, nonUserArray: nonUserArray)
    }
    
    
    
    
    //    pop-up used to ask if the user would like to invite their friends who are not users yet
    func inviteFriendsPopUp(notExistingUserArray: [String], nonExistingNameArray: [String]){
        
        print("inviteFriendsPopUp Initiated")
        
        let displayArray = nonExistingNameArray.joined(separator:", ")
        
        // create the alert
        let alert = UIAlertController(title: "Not all the friends you invited are Circleit App users", message: "Would you like to invite \(displayArray) to  Circleit?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: { action in
            
//            self.eventAdditionComplete()
            
        }))
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
            
            print("User Selected to send texts to thier friends")
//            self.sendInviteTextMessages(notExistingUserArray: notExistingUserArray)
            
            self.shareLinkToTheEvent()
            
//            self.eventAdditionComplete()
            
        }))
        
        // show the alert
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
        

    }
    
    func eventAdditionComplete(){
        
//        performSegue(withIdentifier: "eventCreatedSegue", sender: self)
        
        
        print("running func eventAdditionComplete")
        
        //Zubair: You can write UIAlertController code within an extension of UIViewController so that you don't have to create it every time you need to use it.
        let alertEventComplete = UIAlertController(title: "Congratualtions! Your event has been created", message: "Check 'Your Events' to see responses", preferredStyle: UIAlertController.Style.alert)
        
        alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            print("User Selected OK on event creation alert")
            
            self.performSegue(withIdentifier: "eventSummaryComplete", sender: self)
            
            
            
            
        }))
        
        if self.presentedViewController == nil {
            self.present(alertEventComplete, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alertEventComplete, animated: true, completion: nil)
        }
        
        }
    
    
func resultsResponseComplete(){
            
    //        performSegue(withIdentifier: "eventCreatedSegue", sender: self)
            
            
            print("running func resultsResponseComplete")
            
            let alertEventComplete = UIAlertController(title: "Availability Added! ", message: "Your availability has been added to the event", preferredStyle: UIAlertController.Style.alert)
            
            alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                
                print("User Selected OK on event creation alert")
                
                
                
                
            }))
            
            if self.presentedViewController == nil {
                self.present(alertEventComplete, animated: true, completion: nil)
            }
            else {
                self.dismiss(animated: false, completion: nil)
                self.present(alertEventComplete, animated: true, completion: nil)
            }
            
            }
    
    
//    retrieves each users availability for the event
    func addUserToEventArray2( eventID: String, noResultArray: Array<Any>, completion: @escaping (_ arrayForEventResultsPage: [[Any]]) -> Void){
    
    print("running func addUserToEventArray2 inputs - eventID: \(eventID) noResultArray: \(noResultArray)")
    
        var emptyArray = Array<Any>()
        var arrayForEventResultsPageAvailability = [[Any]]()
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        //Zubair: Use the global firebase manager class.
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else { emptyArray.removeAll()
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                    
                    let userAvailability = document.get("userAvailability") as? [Any]
                    var userID = document.get("uid") as? String
                    let documentID = document.documentID
                    
                    if userAvailability == nil {
                        emptyArray = noResultArray
                        
                    }
                    else if userAvailability?.count == 0 {
                        emptyArray = noResultArray
                        
                    }
                        
                    else {
                        
                        emptyArray = document.get("userAvailability") as! [Int]
                        
                        if userID == user{
                            
                            currentUsersAvailability = emptyArray as! [Int]
                            currentUserAvailabilityDocID = documentID
                            
                        }
                        else{
                            print("not the current user")
                        }
                        
                        
                    }
                    
                    
                    emptyArray.insert(document.get("userName")!, at: 0)
                    arrayForEventResultsPageAvailability.append(emptyArray)
                    
                }
                
            }
            completion(arrayForEventResultsPageAvailability)
        }
    }
    
    func addNonExistentUsers( eventID: String, noResultArray: Array<Any>, completion: @escaping (_ arrayForEventResultsPage: [[Any]], _ nonExistentNames: Array<Any>) -> Void){
        
        print("running func addNonExistentUsers inputs - eventID: \(eventID) noResultArray: \(noResultArray)")
        
        var emptyArray = Array<Any>()
        var addNonExistentUsersAvailability = [[Any]]()
        var nonExistentNames = Array<Any>()
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        //Zubair: Use the global firebase manager class
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else { emptyArray.removeAll()
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                    
                    let name = document.get("name") ?? "Unknown Name"
  
                    emptyArray = noResultArray
                    emptyArray.insert(name, at: 0)
                    nonExistentNames.append(name)
                    addNonExistentUsersAvailability.append(emptyArray)
                }
                
            }
            completion(addNonExistentUsersAvailability, nonExistentNames)
        }
    }
    
    
//    function to delete non users from the temporary user event store
    
    func deleteNonUsers(eventID: String, userNames: [String]){
        
        
        print("running func deleteNonUsers inputs - eventID: \(eventID) userNames: \(userNames)")
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        for names in userNames{
        //Zubair: Use the global firebase manager class
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).whereField("name", isEqualTo: names).getDocuments() { (querySnapshot, err) in
            
            print("querySnapshot: \(String(describing: querySnapshot))")
            
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    print("documentID: \(documentID)")
                    
                    docRefUserEventStore.document(documentID).delete()
                }
                
            }
            
        }
        
        
    }
    }
    
    func getDayOfTheWeekArray2(eventID: String, userEventStoreID: String, completion: @escaping (_ daysOfTheWeek2: [Int], _ userEventStoreID: String) -> Void){
        
        
        print("running func getDayOfTheWeekArray2 inputs - eventID: \(eventID)")
        
        //Zubair: Use the global firebase manager class
        let docRef = dbStore.collection("eventRequests").document(eventID)
        print(eventID)
        var daysOfTheWeek2 = [Int]()
        
        docRef.getDocument(
            completion: { (document, error) in
                if error != nil {
                    print("Error getting documents")
                }
                else {
                    
                    daysOfTheWeek2 = document?.get("daysOfTheWeek") as? [Int] ?? [10,10,10,10,10,10,10]
                    
                    print("daysOfTheWeek2 \(daysOfTheWeek2)")
                    completion(daysOfTheWeek2, userEventStoreID)
                    
                }})
    
    }
    
    
    func checkCalendarStatus2(){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar2()
        case EKAuthorizationStatus.authorized:
            print("We got access to the calendar")
            loadCalendars2()
        case EKAuthorizationStatus.denied:
            print("No access to the calendar")
            requestAccessToCalendar2()
            
        case .restricted:
            print("Access denied to the calendar")
        }
        
    }
    
    //        request access to the users calendar
    func requestAccessToCalendar2() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                //                print("we got access")
            }
            else{
                print("no access to the calendar")
            }
            
        })
    }
    
    
    
    func getCalendarData2(startDate: Date, endDate: Date) -> (datesOfTheEvents: Array<Date>, startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>){
        
        
        print("running func getCalendarData2 inputs - startDate: \(startDate) endDate: \(endDate)")
        
        var datesOfTheEvents = Array<Date>()
        var startDatesOfTheEvents = Array<Date>()
        var endDatesOfTheEvents = Array<Date>()
        var calendarToUse: [EKCalendar]?
        if SelectedCalendarsStruct.calendarsStruct.count == 0 {
            calendarToUse = calendars
            
            print("calendars being used \(String(describing: calendarToUse))")
            
        }
        else{
            calendarToUse = SelectedCalendarsStruct.calendarsStruct
            
            print("calendars being used \(String(describing: calendarToUse))")
            
        }
        datesOfTheEvents.removeAll()
        startDatesOfTheEvents.removeAll()
        endDatesOfTheEvents.removeAll()
        calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: calendarToUse))
        
        
        print("Start date of the period to search \(startDate)")
        print("End date of the period to search \(endDate)")
        
        //                print(calendarArray)
        
        numberOfItems = calendarArray.count
        
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
            
            //                creates an array of the dates on which the user has events
            datesOfTheEvents.append(event.occurrenceDate)
            startDatesOfTheEvents.append(event.startDate)
            endDatesOfTheEvents.append(event.endDate)
            
            print("dates of the events \(datesOfTheEvents)")
            print("start dates of the events \(startDatesOfTheEvents)")
            print("end dates of the events \(endDatesOfTheEvents)")
            
        }
        
        return (datesOfTheEvents: datesOfTheEvents, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
        
        
    }
    
    
    
    func commitUserAvailbilityData(userEventStoreID: String, finalAvailabilityArray2: [Int]){
    
        print("running func commitUserAvailbilityData inputs - userEventStoreID: \(userEventStoreID) finalAvailabilityArray2: \(finalAvailabilityArray2)")
    
    
    dbStore.collection("userEventStore").document(userEventStoreID).setData(["userAvailability" : finalAvailabilityArray2], merge: true)
    
    }
    
//    function to adjust the days of the week for timezones, if the users is in a timezone where there start date of thier event will be the next day we adjust thier days of the week array forward one day
    func adjustDaysOfWeekArrayForTZ(daysOfTheWeek: [Int], hoursToGMT: Int, startTime: String) -> [Int]{
        
      print("running func adjustDaysOfWeekArrayForTZ inputs - daysOfTheWeek: \(daysOfTheWeek) hoursToGMT: \(hoursToGMT) startTime: \(startTime)")
        
        var useableTime = Int()
        var n = 6

        var newDaysOfTheWeek = [Int]()
        
//      convert the time into a useable
        useableTime = Int(startTime[..<2].string) ?? 0
        print("useableTime: \(useableTime)")
        print("useableTime + hoursToGMT: \(useableTime + hoursToGMT)")
        
        if useableTime + hoursToGMT < 0 {
            
            while n >= 0 {
                
                if n == 0 && daysOfTheWeek[6] != 10 && daysOfTheWeek[0] != 10{
                    
                  
                    newDaysOfTheWeek.insert(0, at: 0)
                    newDaysOfTheWeek[1] = 1
                }
                else if n == 0 && daysOfTheWeek[6] != 10{
                    
                    newDaysOfTheWeek.insert(0, at: 0)
                    newDaysOfTheWeek[1] = 10
                }
                else if n == 0 && daysOfTheWeek[0] == 10{
                    
                    newDaysOfTheWeek.insert(10, at: 0)
                    newDaysOfTheWeek[1] = 10
                }
                else if daysOfTheWeek[n - 1] != 10{
                   newDaysOfTheWeek.insert(n, at: 0)
                }
                else if daysOfTheWeek[n - 1] == 10{
                    newDaysOfTheWeek.insert(10, at: 0)
                }
                
                n = n - 1
            }
            print("newDaysOfTheWeek: \(newDaysOfTheWeek)")
            return newDaysOfTheWeek
            
        }
            
            
        else{
            print("daysOfTheWeek: \(daysOfTheWeek)")
            return daysOfTheWeek
            
            
        }
        
    
    }
    
    
//    function to adjust the days of the week array for event end times that end the following day
    func adjustDaysOfWeekArrayForLateEnd(daysOfTheWeek: [Int]) -> [Int]{
        
        print("running func adjustDaysOfWeekArrayForTZLateEnd inputs - daysOfTheWeek: \(daysOfTheWeek)")
        
        var n = 0
        
        var newDaysOfTheWeek = [0]

            while n <= 6 {
                
                if n == 6 && daysOfTheWeek[n] != 10 && daysOfTheWeek[n - 1] != 10{
                   newDaysOfTheWeek[0] = 0
                    newDaysOfTheWeek[6] = 6
   
                }
                else if n == 6 && daysOfTheWeek[n] != 10 && daysOfTheWeek[n - 1] == 10{
                    newDaysOfTheWeek[0] = 0
                    newDaysOfTheWeek[6] = 10
   
                }
                else if n == 6 && daysOfTheWeek[n] == 10 {
                    newDaysOfTheWeek[0] = 10
                }

               else if daysOfTheWeek[n] != 10{
                    
                 newDaysOfTheWeek.insert(n + 1, at: n + 1)
                    
                }
                else if daysOfTheWeek[n] == 10{
                    
                  newDaysOfTheWeek.insert(10, at: n + 1)
                }

                n = n + 1
            }
            return newDaysOfTheWeek
            
        }
    
        
    //        adds the event to the calendar
    func addEventToCalendar(title: String, description: String?, startDate: String, endDate: String, location: String, eventOwner: String, startDateDisplay: String, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        print("running func addEventToCalendar inputs - title: \(title), description: \(description!), startDate: \(startDate), endDate: \(endDate), location:\(location)")
//        let dateFormatterForResultsCreateEvent = DateFormatter()
//        dateFormatterForResultsCreateEvent.dateFormat = "E d MMM HH:mm"
//        dateFormatterForResultsCreateEvent.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormatterTZCreate = DateFormatter()
        dateFormatterTZCreate.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZCreate.locale = Locale(identifier: "en_US_POSIX")
        let displayDate = convertToDisplayDate(inputDate: startDateDisplay)
        

        
        let chosenStartDateDate = dateFormatterTZCreate.date(from:startDate)
        print("chosenStartDateDate: \(String(describing: chosenStartDateDate))")
        let chosenEndDateDate = dateFormatterTZCreate.date(from:endDate)
        print("chosenEndDateDate: \(String(describing: chosenEndDateDate))")
    
        
        let eventStore = EKEventStore()
        
        let alert = UIAlertController(title: "Event Date Chosen", message: "\(eventOwner) invited you to the event \( description!), on \(displayDate), would you like to add it to your calendar?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { action in
            print("user chose to save down the new event")
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = title
                    print("Event being saved: Title \(String(describing: event.title))")
                    event.location = location
                    print("Event being saved: Location \(String(describing: event.location))")
                    event.startDate = chosenStartDateDate
                    print("Event being saved: startDate \(String(describing: event.startDate))")
                    event.endDate = chosenEndDateDate
                    print("Event being saved: endDate \(String(describing: event.endDate))")
                    event.notes = description
                    print("Event being saved: description \(String(describing: event.description))")
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    print("Event being saved: calendar being saved to \(String(describing: event.calendar))")
                    do {
                        try eventStore.save(event, span: .thisEvent)
                        print("Trying to save down event")
                    } catch let e as NSError {
                        completion?(false, e)
                        return
                    }
                    completion?(true, nil)
                    print("event saved for date \(startDate)")
                } else {
                    completion?(false, error as NSError?)
                    print(error ?? "no error message")
                    print("error saving event")
                }})}))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { action in
            print("user chose not to save the new event")
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
//    function to calculate the number of respondents who are available
    func resultsSummary(resultsArray: [[Any]]) -> (countedResults: [[Any]], fractionResults: [[Float]]){
        
        print("running func resultsSummary - inputs - resultsArray: \(resultsArray)")
        
        countedResultArrayFraction.removeAll()
        
        var resultCounter = 0
        var countedResultArray = [Any]()
        
        //        number of rows in the results array, we only loop through those that include results
        let numberOfRows = resultsArray.count
        
        print("numberOfRows: \(numberOfRows)")
        
        let numberOfColumns = resultsArray[1].count
        print("numberOfColumns: \(numberOfColumns)")
        
        var n = 1
        var y = 1
        
        
        //        0 = row
//        print(resultsArray[0][2])
        
        
        while n <= numberOfColumns - 1  {
            
            while y <= numberOfRows - 1 {
                
                if resultsArray[y][n] as! Int == 1{
                    
                    resultCounter = resultCounter + 1
                    
                }
                else{
                    //                    don't do anything
                }
                y = y + 1
                
            }
            countedResultArray.append("\(resultCounter)/\(numberOfRows - 1)")
            countedResultArrayFraction.append((Float(Double(resultCounter)/(Double(numberOfRows - 1)))))
            resultCounter = 0
            y = 1
            n = n + 1
            
        }
        
        countedResultArray.insert("Availability", at: 0)
        
        
        print("countedResultArray: \(countedResultArray) countedResultArrayFraction \(countedResultArrayFraction)")
        return (countedResults: [countedResultArray], fractionResults: [countedResultArrayFraction])
        
    }
    
    func dateInXDays(increment: Int, additionType: Calendar.Component) -> Date{
        
        let todaysDate = Date()
        let calendar = NSCalendar.current
        
        let newDate = calendar.date(byAdding: additionType, value: increment, to: todaysDate)!
        
        
        return newDate
        
    }
    
    
    //    input formats dates: yyyy-MM-dd
    func getStartAndEndDates3(startDate: String, endDate: String, startTime: String, endTime: String, daysOfTheWeek: [Int], completion: @escaping (_ startDates: [String], _ endDates: [String]) -> Void){
        
        print("running func getStartAndEndDates3 inputs - startDate: \(startDate) endDate: \(endDate) startTime: \(startTime) endTime: \(endTime) daysOfTheWeek: \(daysOfTheWeek)")
        
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        var hoursFromGMT = secondsFromGMT / 3600
        var hoursFromGMTString = String()
        if hoursFromGMT >= 0{
            hoursFromGMTString = ("+\(hoursFromGMT)")
            
        }
        else{
           hoursFromGMTString = ("\(hoursFromGMT)")
            
        }
        var startDates = [String]()
        var endDates = [String]()
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        let dateFormatterTime = DateFormatter()
        let tz = TimeZone.current.abbreviation()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        
        //        create a start and end date with time from the strings input into the function
        
      
        let startDateString = ("\(startDate) \(startTime) GMT\(hoursFromGMTString)")
        print("startDateString: \(startDateString)")
        let startEndDateString = ("\(startDate) \(endTime) GMT\(hoursFromGMTString)")
        print("startEndDateString: \(startEndDateString)")
        let endDateString = ("\(endDate) \(endTime) GMT\(hoursFromGMTString)")
        print("endDateString: \(endDateString)")
        
        //        convert the sring dates into NSDates
        var startDateDate = dateFormatter.date(from: startDateString)
        print("startDateDate: \(startDateDate!)")
        var startEndDateDate = dateFormatter.date(from: startEndDateString)
        print("startDateDate: \(startDateDate!)")
        let endDateDate = dateFormatter.date(from: endDateString)
        print("endDateDate: \(endDateDate!)")
        
        startDates.removeAll()
        endDates.removeAll()
        
        while startDateDate! <= endDateDate! {
            
            let startDateDateString = dateFormatter.string(from: startDateDate!)
            let dayOfWeekStart = getDayOfWeek3(startDateDateString)! - 1
            print("dayOfWeekstart: \(dayOfWeekStart)")
            
            if daysOfTheWeek.contains(dayOfWeekStart) {
                
                startDates.append(startDateDateString)
                startDateDate = calendar.date(byAdding: .day, value: 1, to: startDateDate!)!
                
            }
            else{
                
                startDateDate = calendar.date(byAdding: .day, value: 1, to: startDateDate!)!
                
            }
            
        }
        print("startDates: \(startDates)")
        
        var endDatetz = endDateDate!

        
        while startEndDateDate! <= endDatetz {
            
//            We need to adjust the end time when coming out of daylight savings time, if the current date we are checking is not in daylight savings time then we move the hour of the end date forward by 1
            
            let dayLight = TimeZone.current
            
            if dayLight.isDaylightSavingTime(for: startEndDateDate!) {
                
                endDatetz = endDateDate!
   
            }
            else{

                endDatetz = calendar.date(byAdding: .hour, value: 1, to: endDateDate!)!
                
            }
            
            let startEndDateDateString = dateFormatter.string(from: startEndDateDate!)
            let dayOfWeekEnd = getDayOfWeek3(startEndDateDateString)! - 1
            //            print("dayOfWeekEnd: \(dayOfWeekEnd)")
            
            if daysOfTheWeek.contains(dayOfWeekEnd) {
                
                endDates.append(startEndDateDateString)
                startEndDateDate = calendar.date(byAdding: .day, value: 1, to: startEndDateDate!)!
                
            }
            else{
                
                startEndDateDate = calendar.date(byAdding: .day, value: 1, to: startEndDateDate!)!
                
            }
            
        }
        print("endDates: \(endDates)")
        
        completion(startDates, endDates)
        
    }
    
    func getDayOfWeek3(_ today:String) -> Int? {
        
        //        print("running func getDayOfWeek2 inputs - today: \(today)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        //        print("weekday \(weekDay)")
        return weekDay
    }
    
    
    func compareTheEventTimmings3(datesBetweenChosenDatesStart: [String], datesBetweenChosenDatesEnd: [String], startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>) -> Array<Int>{
        print("running func compareTheEventTimmings3 inputs - datesBetweenChosenDatesStart:\(datesBetweenChosenDatesStart) datesBetweenChosenDatesEnd: \(datesBetweenChosenDatesEnd) startDatesOfTheEvents:\(startDatesOfTheEvents) endDatesOfTheEvents: \(endDatesOfTheEvents)")
        let numeberOfDatesToCheck = datesBetweenChosenDatesStart.count - 1
        print("numeberOfDatesToCheck: \(numeberOfDatesToCheck)")
        let numberOfEventDatesToCheck = startDatesOfTheEvents.count - 1
        var finalAvailabilityArray = Array<Int>()
        var n = 0
        var y = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        finalAvailabilityArray.removeAll()
        
//        validation to cofirm the data pulled from the database is correct, we have the same number of start and end dates
        if datesBetweenChosenDatesStart.count == 0 || datesBetweenChosenDatesEnd.count == 0 || datesBetweenChosenDatesStart.count != datesBetweenChosenDatesEnd.count{
            
            print("Fatal Error, one of the date lists is empty")
            
        }
//            If the user doesn't have any events in thier calendar for the period we create a useravailability array of 0
        if startDatesOfTheEvents.count == 0{
            
            print("User deosn't have events in thier calendar for this period")
        
            while y <= numeberOfDatesToCheck{
                print("y \(y)")
                
                finalAvailabilityArray.append(1)
                
                y = y + 1
     
            }
            
            
        }
            
        else{
            
            
            datesLoop: while y <= numeberOfDatesToCheck {
                
                print("y \(y)")
                
                eventsLoop: while n <= numberOfEventDatesToCheck {
                    //                debug only
                    //                            print("n \(n)")
                    //                            print("Start dates between chosen dates \(datesBetweenChosenDatesStart)")
                    //                            print("End dates between chosen dates\(datesBetweenChosenDatesEnd)")
                    //                            print("Start Date of the events to check \(startDatesOfTheEvents)")
                    //                            print("End Date of the events to check \(endDatesOfTheEvents)")
                    //                            print("Date Test Start: Start Date \(datesBetweenChosenDatesStart[y]) End Date \(datesBetweenChosenDatesEnd[y]) Date to test \(startDatesOfTheEvents[n])")
                    //                            print("Date Test End: Start Date \(datesBetweenChosenDatesStart[y]) End Date \(datesBetweenChosenDatesEnd[y]) Date to test \(endDatesOfTheEvents[n])")
                    
                    let datesBetweenChosenDatesStartDate = dateFormatter.date(from: datesBetweenChosenDatesStart[y])!
                    let datesBetweenChosenDatesEndDates = dateFormatter.date(from: datesBetweenChosenDatesEnd[y])!
                    
                    if startDatesOfTheEvents[n] < datesBetweenChosenDatesStartDate && endDatesOfTheEvents[n] > datesBetweenChosenDatesEndDates || (datesBetweenChosenDatesStartDate ... datesBetweenChosenDatesEndDates).contains(startDatesOfTheEvents[n]) == true || (datesBetweenChosenDatesStartDate ... datesBetweenChosenDatesEndDates).contains(endDatesOfTheEvents[n]) == true{
                        print("within the dates to test")
                        finalAvailabilityArray.append(0)
                        print(finalAvailabilityArray)
                        n = 0
                        if y == numeberOfDatesToCheck{
                            
                            print("break point y checks complete: \(y) numeberOfDatesToCheck \(numeberOfDatesToCheck)")
                            
                            break datesLoop
                            
                        }
                        else{
                            y = y + 1
                            n = 0
                        }
                        
                    }
                    else {
                        
                        if n == numberOfEventDatesToCheck && y == numeberOfDatesToCheck{
                            finalAvailabilityArray.append(1)
                            print(finalAvailabilityArray)
                            print("Outside dates to test and end of the list of event dates and dates to test")
                            
                            
                            break datesLoop
                            
                        }
                        else if n == numberOfEventDatesToCheck{
                            print("Outside dates to test and end of the list of dates to test, going to next event date")
                            finalAvailabilityArray.append(1)
                            print(finalAvailabilityArray)
                            y = y + 1
                            n = 0
                        }
                        else{
                            print("Outside dates to test")
                            
                            n = n + 1
                        }
                    }
                    
                }
                n = n + 1
                
            }}
        print(finalAvailabilityArray)
        return finalAvailabilityArray
    }
    
    
    func getArrayOfChosenDates3(eventID: String, completion: @escaping (_ startDates: [String], _ endDates: [String]) -> Void){
        
        print("running func getArrayOfChosenDates3 - with inputs eventID: \(eventID)")
    
        let docRef = dbStore.collection("eventRequests").document(eventID)
        var startDates = [String]()
        var endDates = [String]()
        
        //Zubair: Use the global firebase manager class
        docRef.getDocument(
            completion: { (document, error) in
                if error == nil {
                    
                    startDates = document!.get("startDates") as! [String]
                    endDates = document!.get("endDates") as! [String]
                    
                    print("getArrayOfChosenDates3 output startDates: \(startDates), endDates: \(endDates)")
                    
                    completion(startDates,endDates)
                    
                }
                else{
                    
                    print("error getting documents \(String(describing: error))")
                    
                    completion(startDates,endDates)
                    print("getArrayOfChosenDates3 output startDates: \(startDates), endDates: \(endDates)")
                }
        })

    }
    
    func getCalendarData3(startDate: Date, endDate: Date) -> (datesOfTheEvents: Array<Date>, startDatesOfTheEvents: Array<Date>, endDatesOfTheEvents: Array<Date>){
        
        
        print("running func getCalendarData2 inputs - startDate: \(startDate) endDate: \(endDate)")
        
        var datesOfTheEvents = Array<Date>()
        var startDatesOfTheEvents = Array<Date>()
        var endDatesOfTheEvents = Array<Date>()
        var calendarToUse: [EKCalendar]?
        let eventStore = EKEventStore()
        var calendarArray = [EKEvent]()
        var calendarEventArray : [Event] = [Event]()
        if SelectedCalendarsStruct.calendarsStruct.count == 0 {
            calendarToUse = calendars}
        else{
            calendarToUse = SelectedCalendarsStruct.calendarsStruct}
        datesOfTheEvents.removeAll()
        startDatesOfTheEvents.removeAll()
        endDatesOfTheEvents.removeAll()
        calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: calendarToUse))
        
        print("Start date of the period to search \(startDate)")
        print("End date of the period to search \(endDate)")
        
        //                print(calendarArray)
        
        
        for event in calendarArray{
            
            //            appends new items into the array calendarEventsArray
            let newItemInArray = Event()
            newItemInArray.alarms = event.alarms
            newItemInArray.title = event.title
            newItemInArray.location = event.location ?? ""
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
            
            //                creates an array of the dates on which the user has events
            datesOfTheEvents.append(event.occurrenceDate)
            startDatesOfTheEvents.append(event.startDate)
            endDatesOfTheEvents.append(event.endDate)
            
            print("dates of the events \(datesOfTheEvents)")
            print("start dates of the events \(startDatesOfTheEvents)")
            print("end dates of the events \(endDatesOfTheEvents)")
            
        }
        
        return (datesOfTheEvents: datesOfTheEvents, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
        
        
    }
    
    //    function used to pull down the information of the event stored in the Firebase database
    func getEventInformation3(  eventID:String, userEventStoreID: String, completion: @escaping (_ userEventStoreID: String, _ eventSecondsFromGMT: Int, _ startDates: [String], _ endDates: [String]) -> Void) {
        
        print("running func getEventInformation3 inputs - eventID: \(eventID)")
        
        let dateFormatterTime = DateFormatter()
        let dateFormatterSimple = DateFormatter()
        let dateFormatterTZ = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterSimple.dateFormat = "yyyy-MM-dd"
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterSimple.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
        //Zubair: Use the global firebase manager class
        let docRef = dbStore.collection("eventRequests").document(eventID)
        
        docRef.getDocument(
            completion: { (document, error) in
                if error != nil || document!.get("startDateInput") == nil {
                    print("Error getting documents")
                }
                else {
                    let eventSecondsFromGMT = document!.get("secondsFromGMT") as! Int
                    print("eventSecondsFromGMT: \(eventSecondsFromGMT)")
                    let endDates = document!.get("endDates") as! [String]
                    let startDates = document!.get("startDates") as! [String]
                    daysOfTheWeek = document!.get("daysOfTheWeek") as! [Int]
       
                        completion( userEventStoreID, eventSecondsFromGMT, startDates, endDates)
                    }
                
        })}
    
    
    
    func loadCalendars2(){
        
        var calendars: [EKCalendar]!
         
            calendars = eventStore.calendars(for: EKEntityType.event)
        
        
            
    //        If the calendar array hasnt been created previously then then the function creates a new array
            if SelectedCalendarsStruct.calendarsStruct.count == 0 {
                
                SelectedCalendarsStruct.calendarsStruct = calendars!
                
                
                    SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "US Holidays"})
                    
                    SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "UK Holidays"})
                    
                    SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "Birthdays"})
                
                SelectedCalendarsStruct.calendarsStruct.removeAll(where: {$0.title == "Holidays in United Kingdom"})
                
                
                    
//                    defaults.set(SelectedCalendarsStruct.calendarsStruct, forKey: "selectedCalendars")
                    
                    print("SelectedCalendarsStruct: \(SelectedCalendarsStruct.calendarsStruct)")
   
            }
                else{
                    
                    
                    
                }
        
        
        

            }
    
    
    
    func shareLinkToTheEvent(){
        
        let firstActivityItem = "Hey, I've invited you to an event on the Circleit App, download the App to respond ***To give access email the beta link in Testflight***"
                let secondActivityItem : NSURL = NSURL(string: "http//www.circleitapp.com")!
                // If you want to put an image
        //        let image : UIImage = UIImage(named: "image.jpg")!

                let activityViewController : UIActivityViewController = UIActivityViewController(
                    activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

                // Anything you want to exclude
                activityViewController.excludedActivityTypes = [
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.print,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.addToReadingList,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.airDrop,
                    UIActivity.ActivityType.markupAsPDF,
                    UIActivity.ActivityType.openInIBooks,
                    UIActivity.ActivityType.postToTwitter,
                ]

                self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    //Zubair: Use the global firebase manager class
    func signOut(){
      
         let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
            
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        
    }
    

    func checkUserInUserDatabase(){
        
        
        if existingUserLoggedIn == false{
            
        }
        else{
        
        let phoneNumber = UserDefaults.standard.value(forKey: "userPhoneNumber")
        
        //Zubair: Use the global firebase manager class
        dbStore.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber!).getDocuments { (querySnapshot, error) in
        
                        print("querySnapshot from user check \(String(describing: querySnapshot))")
        
                        if error != nil {
                            print("there was an error")
                        }
                        else {
                            print("querySnapshot!.isEmpty: \(querySnapshot!.isEmpty)")
        
                            if querySnapshot!.isEmpty {
        
                                print("Empty: querysnapshot: \(String(describing: querySnapshot)), isEmpty: \(String(describing: querySnapshot!.isEmpty))")
        
                                    let alertEventComplete = UIAlertController(title: "Phone number not registered", message: "This phone number isn't linked to an account, please register", preferredStyle: UIAlertController.Style.alert)
        
                                    alertEventComplete.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
        
                                        print("User Selected OK on event creation alert")
        
                                        print("performing notAUserSegue segue")
                                        
                                        self.signOut()
        
                                        self.performSegue(withIdentifier: "userNotInDatabase", sender: self)
        
                                    }))
                                    self.present(alertEventComplete, animated: true, completion: {
                                    })
                                }
                            else {
                                
                                for documents in querySnapshot!.documents{
                                    
                                    let name = documents.get("name")
                                    
                                    UserDefaults.standard.set(name, forKey: "name")
                                    
                                    print("user is in the database")
                                    
                                }
                                
                                

                            }}}}
        }

    //    end of globally available functions
    
}




extension StringProtocol {
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    subscript(_ range: Range<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
//examples
//let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[safe: 10]   // "🇺🇸"
//test[11]   // "!"
//test[10...]   // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[10..<12]   // "🇺🇸!"
//test[10...12]   // "🇺🇸!!"
//test[...10]   // "Hello USA 🇺🇸"
//test[..<10]   // "Hello USA "
//test.first   // "H"
//test.last    // "!"
//
//// Subscripting the Substring
//test[...][...3]  // "Hell"
//
//// Note that they all return a Substring of the original String.
//// To create a new String you need to add .string as follow
//test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!"

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CreateEventViewController: UICollectionViewDelegateFlowLayout {
    
//    spacing between the cells, i.e in the middle of the screen
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 4
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth/2 - 50, height: screenWidth/2 - 50)
}
}
