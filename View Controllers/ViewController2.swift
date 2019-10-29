//
//  CreateEventViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MBProgressHUD
import Instructions


var myArray = [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]]
var vc = ViewController()
var eventIDChosen = String()
var inviteesNamesLocation = [String]()
var arrayForEventResultsPageFinal = [[Any]]()
var nonUserInviteeNames = Array<String>()


class ViewController2: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    
    
    
     var arrayForEventResultsPage = [[Any]]()
    var buttonHidden = false
    var selectedRow = Int()
    var cgRectIndex = CGRect()
    let redColour = UIColor.init(red: 255, green: 235, blue: 230)
    let greenColour = UIColor.init(red: 191, green: 241, blue: 160)
    let circleitColour = UIColor(red: 0, green: 176, blue: 156)
    let coachMarksController = CoachMarksController()
    
    

    @IBOutlet var dropDownButton: UIButton!
    
    
    
    @IBOutlet var chosenDateLabel: UILabel!
    
    @IBOutlet var submitChosenDateButton: UIButton!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    @IBOutlet weak var okLabel: UILabel!
    
    @IBOutlet weak var unavailableLabel: UILabel!
    
    
    
    
    @IBOutlet weak var circleItButton: UIButton!
    
    
    
    @IBOutlet weak var bestDates: UILabel!
    
    
    
    @IBOutlet weak var viewBestDatesButton: UIButton!
    
    
    @IBAction func respondNowButtonTapped(_ sender: Any) {
        
        automaticallyRespondNow()
        
    }
    
    
    @IBOutlet weak var automaticAvailabilityButton: UIButton!
    
    
    
    @IBAction func automaticAvailabilityButtonPressed(_ sender: Any) {
        
        automaticallyRespondNow()
    }
    
    
    
    @IBOutlet weak var manualAddAvailability: UIButton!
    
    
    
    
	@IBOutlet weak var gridCollectionView: UICollectionView! {
		didSet {

//            not sure what this setting does
//			gridCollectionView.bounces = true

		}
	}
    
//    sets the number of columns and rows that do not move with the table
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
            
            if selectEventToggle == 1 {
			gridLayout.stickyRowsCount = 1
                gridLayout.stickyColumnsCount = 1}
            
            else{
                
                gridLayout.stickyRowsCount = 1
                gridLayout.stickyColumnsCount = 1
                
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        navigation bar setup
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: "Circle",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        
        
        navTitle.append(NSMutableAttributedString(string: "it",
                                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        
        
        navLabel.attributedText = navTitle
        
        
        let navTitle2 = NSMutableAttributedString(string: "Circle",
        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        navTitle2.append(NSMutableAttributedString(string: " it",
        attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        circleItButton.titleLabel?.attributedText = navTitle2
        
        self.navigationItem.titleView = navLabel
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor.black
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        
        
        okLabel.backgroundColor = greenColour
        unavailableLabel.backgroundColor = redColour
        okLabel.text = "✔️"
        unavailableLabel.text = "❌"
        
        bestDates.layer.borderWidth = 4
        bestDates.layer.borderColor = circleitColour.cgColor
        bestDates.layer.cornerRadius = 10
        
        gridCollectionView.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        

        
        gridCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
       
//        setup view best dates button
        viewBestDatesButton.layer.borderColor = UIColor.lightGray.cgColor
        viewBestDatesButton.layer.borderWidth = 2
        viewBestDatesButton.layer.cornerRadius = 5
        viewBestDatesButton.layer.backgroundColor = UIColor(red: 0, green: 176, blue: 156).cgColor
        
        viewBestDatesButton.layer.shadowColor = UIColor.lightGray.cgColor
        viewBestDatesButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        viewBestDatesButton.layer.shadowRadius = 4
        viewBestDatesButton.layer.shadowOpacity = 0.5
        viewBestDatesButton.layer.masksToBounds = false
        
        
//        setup automatic availability button
        
        automaticAvailabilityButton.layer.borderColor = UIColor.lightGray.cgColor
        automaticAvailabilityButton.layer.borderWidth = 2
        automaticAvailabilityButton.layer.cornerRadius = 5
        automaticAvailabilityButton.layer.backgroundColor = UIColor.white.cgColor
        
        automaticAvailabilityButton.layer.shadowColor = UIColor.lightGray.cgColor
        automaticAvailabilityButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        automaticAvailabilityButton.layer.shadowRadius = 4
        automaticAvailabilityButton.layer.shadowOpacity = 0.5
        automaticAvailabilityButton.layer.masksToBounds = false
        
        
        //        setup manual availability button
        
        manualAddAvailability.layer.borderColor = UIColor.lightGray.cgColor
        manualAddAvailability.layer.borderWidth = 2
        manualAddAvailability.layer.cornerRadius = 5
        manualAddAvailability.layer.backgroundColor = UIColor.white.cgColor
        
        manualAddAvailability.layer.shadowColor = UIColor.lightGray.cgColor
        manualAddAvailability.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        manualAddAvailability.layer.shadowRadius = 4
        manualAddAvailability.layer.shadowOpacity = 0.5
        manualAddAvailability.layer.masksToBounds = false
        
        
      dateChosenCheck()
        getUsersNames()
        chosenDateLabel.adjustsFontSizeToFitWidth = true
        
        
        //        ***For coachMarks
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true

        
        
        if summaryView == true{
            
            navigationItem.hidesBackButton = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneSelected))
            
            
        }
        else{
            
            navigationItem.backBarButtonItem?.isEnabled = true
            
            //        create the edit button
            createEditButon()
            
        }
        

        
        gridCollectionView.heightAnchor.constraint(equalToConstant: screenHeight - 380).isActive = true
        
        

        
        
//        set label details
        
        let eventDescription = eventResultsArrayDetails[2][1] as? String
        
        let startTime = convertToLocalTime(inputTime: eventResultsArrayDetails[6][0] as! String)
        let endTime = convertToLocalTime(inputTime: eventResultsArrayDetails[7][0] as! String)
        let eventLocation = eventResultsArrayDetails[1][1] as! String
        
        
        eventTitleLabel.text = eventDescription!
        eventLocationLabel.text = ("\(eventLocation) (\(startTime) - \(endTime))")
        
        print(eventResultsArrayDetails.count)
        
        if eventResultsArrayDetails[10] as? [String] == nil {
        nonUserInviteeNames = [""]

        }
        else{
            nonUserInviteeNames = eventResultsArrayDetails[10] as! [String]


        }
        
        print("nonUserInviteeNames: \(nonUserInviteeNames)")
        
        

    }
    
    
//    create the edit button
    
    func createEditButon(){
        
        
        if selectEventToggle == 0{
            print("no edit button")
            viewBestDatesButton.isHidden = true
            
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editSelected))
            
        }
        
    }
    
    
//    Segue to edit the event page
    @objc func editSelected(){
        
        
        
        performSegue(withIdentifier: "eventSettings", sender: (Any).self)
        
        
//        clears the contacts list when edit is selected
        contactsSelected.removeAll()
        contactsSorted.removeAll()
        
        
        
    }
    
    
    //    Segue to edit the event page
        @objc func doneSelected(){
            
            
            
            performSegue(withIdentifier: "issueWithArraySegue", sender: (Any).self)
            
            
            
        }
    
//    Gets the users names
    func getUsersNames(){
        
        if selectEventToggle == 0{
        }
        else{
        
            inviteesNames.removeAll()
            inviteesNamesNew.removeAll()
            inviteesNamesLocation.removeAll()
            deletedUserIDs.removeAll()
            deletedInviteeNames.removeAll()

            
            
//            ****** Made a change here!!
            inviteesUserIDs = eventResultsArrayDetails[8][0] as! Array<String>
            print("inviteesUserIDs \(inviteesUserIDs)")
            let numberOfInvitee = inviteesUserIDs.count - 1
            print("numberOfInvitee: \(numberOfInvitee)")
        

            for items in inviteesUserIDs {

                print("inviteesUserIDs: \(items)")
                
                dbStore.collection("users").whereField("uid", isEqualTo: items).getDocuments { (querySnapshot, error) in
                    if error != nil {
                        print("Error getting documents: \(error!)")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            
                            inviteesNames.append(document.get("name") as! String)
                            inviteesNamesLocation.append(items)
                            
                            print(items)
                            print("inviteesNames: \(inviteesNames)")
                            print("inviteesNamesLocation: \(inviteesNamesLocation)")
                            
                        }}
                }
            }
        }

        }
    
    
    
    func dateChosenCheck(){
        

            if datesToChooseFrom[0] as? String ?? "" == ""{
            
            
            print("dateChosenCheck: No date chosen")
           chosenDateLabel.text = "No date chosen"
            
        }
        else{
            
                chosenDateLabel.text = "Chosen date:  \(convertToDisplayDate(inputDate: datesToChooseFrom[0] as! String))"
            
        }
        
        }



// MARK: - Collection view data source and delegate methods

    
//    number of rows
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let rows = arrayForEventResultsPageFinal.count
        print(arrayForEventResultsPageFinal)
        print("rows: \(rows)")
        return rows
    }

//    number of columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let columns = arrayForEventResultsPageFinal
        let columnsCount = (columns[0] as AnyObject).count!
        
        print(columnsCount)
        
        return columnsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseID, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        if type(of: arrayForEventResultsPageFinal[indexPath.section][indexPath.row]) == Int.self {
            if arrayForEventResultsPageFinal[indexPath.section][indexPath.row] as! Int == 10{
                
            cell.titleLabel.text = "?"
                cell.backgroundColor = UIColor.lightGray
                cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 0
                
            }
        if arrayForEventResultsPageFinal[indexPath.section][indexPath.row] as! Int == 1{
                
                cell.titleLabel.text = "✔️"
            cell.backgroundColor = greenColour
            cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 0
                
            }
            if arrayForEventResultsPageFinal[indexPath.section][indexPath.row] as! Int == 0{
                
                cell.titleLabel.text = "❌"
                cell.backgroundColor = redColour
                cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 0
                
            }
            if arrayForEventResultsPageFinal[indexPath.section][indexPath.row] as! Int == 11{
                
                cell.titleLabel.text = "x"
                cell.backgroundColor = UIColor.orange
                cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 0
                
            }

        }
            else{
            
            var countedResultArrayFractionAdj = countedResultArrayFraction
            
            countedResultArrayFractionAdj.insert(0, at: 0)
            let maxResult = countedResultArrayFractionAdj.max()
            
            if countedResultArrayFractionAdj[indexPath.row] == maxResult && indexPath.section == 1 {
                
                if maxResult == 0{
                    
                    let backgroundColour = UIColor(red: 253, green: 253, blue: 253)
                    
                    cell.backgroundColor = backgroundColour
                    cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
                    cell.titleLabel.text = "\(arrayForEventResultsPageFinal[indexPath.section][indexPath.row])"
                    cell.layer.borderWidth = 0
                    cell.layer.cornerRadius = 0
                    
                }
                else{
                
                let backgroundColour = UIColor(red: 253, green: 253, blue: 253)
                
                            cell.backgroundColor = backgroundColour
                
                            cell.layer.borderWidth = 4
                            cell.layer.borderColor = circleitColour.cgColor
                            cell.layer.cornerRadius = 20
                            cell.titleLabel.text = "\(arrayForEventResultsPageFinal[indexPath.section][indexPath.row])"
                            cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 10)
                    
                }
   
            }
            
            else{

                

            let backgroundColour = UIColor(red: 253, green: 253, blue: 253)

        cell.backgroundColor = backgroundColour
        cell.titleLabel.text = "\(arrayForEventResultsPageFinal[indexPath.section][indexPath.row])"
        cell.titleLabel.font = UIFont(name: "Helvetica Neue", size: 12)
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 0
                    
            }
            
        }


        
        return cell
}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0{
         return CGSize(width: 60, height: 50)
            
        }
        else{
         return CGSize(width: 50, height: 50)
            
        }
        }
    
    //    MARK: - three mandatory methods for choach tips
        
        func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
            
            let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
            

            

            let hintLabels = ["Decided on the date for your event? Press the Circleit button and we'll notify all the invitees","Everyone invited has received a notification, once they open the App their availability will automatically populate","You can manually ammend your availability here","The event details are available on the 'Your Events' section on the home screen"]
            
            let nextlabels = ["OK","OK","OK","OK"]
            
            coachViews.bodyView.hintLabel.text = hintLabels[index]
            
            coachViews.bodyView.nextLabel.text = nextlabels[index]
//            coachViews.bodyView.nextLabel.isEnabled = false
            
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
            
        }
        

        
        
        
        
    //    Defines where the coachmark will appear
        var pointOfInterest = UIView()
        
        func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
            
            
            let hintPositions = [CGRect(x: screenWidth/2 - 67, y: 150, width: 135, height: 35),CGRect(x: 0, y: 220, width: screenWidth, height: screenHeight - 450),CGRect(x: 0, y: screenHeight - 80, width: screenWidth, height: 50),CGRect(x: screenWidth/2 - 67, y: 177, width: 1, height: 1)]
            
            pointOfInterest.frame = hintPositions[index]
            
            
            return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
        }
        
        
        
        
    //    The number of coach marks we wish to display
        func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
            return 3
        }
    
//    When a coach mark appears
    func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int){
        
        print("Coach Index appeared \(index)")
        
        
        
        

        
    }
    
//    when a coach mark dissapears
    func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int){
        

       print("Coach Index disappeared \(index)")
        
        
        if index == 2 {
            
//            add non user invitees
               if nonExistingUsers.count > 0{
                   
                   self.inviteFriendsPopUp(notExistingUserArray: nonExistingNumbers, nonExistingNameArray: nonExistingUsers)
                
                nonExistingUsers.removeAll()
                   
               }
               else{
                
                
            }
            
        }
        
        else{
            print("coachmarks still to present")
        }
        
    }


        
        //    The coach marks must be called from the viewDidAppear and not the ViewDidLoad.
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
                        
                        
            //            TO ADD - check to see if we are on the new page
            
            
            //            positions on the screen for each hint
            
            let createEventCoachMarksCount = UserDefaults.standard.integer(forKey: "createEventCoachMarksCount")
            let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
            
            print("createEventCoachMarksCount \(createEventCoachMarksCount)")
            
            
            if summaryView == true && createEventCoachMarksCount < 4 || createEventCoachMarksPermenant == true{
            
            coachMarksController.start(in: .window(over: self))
                
                UserDefaults.standard.set(createEventCoachMarksCount + 1, forKey: "createEventCoachMarksCount")
                
            }
            else{
                
//                add non user invitees
                if nonExistingUsers.count > 0{
                    
                    self.inviteFriendsPopUp(notExistingUserArray: nonExistingNumbers, nonExistingNameArray: nonExistingUsers)
                    
                    
                    nonExistingUsers.removeAll()
                }
                
            }
        }


    
    
    
    //    The view coachmarks should be removed once the view is removed
    override func viewWillDisappear( _ animated: Bool) {
        super.viewWillDisappear(animated)

        coachMarksController.stop(immediately: true)
    }
    
    
    func automaticallyRespondNow(){
        dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).whereField("eventID", isEqualTo: eventIDChosen).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("there was an error")
                }
                else {
                    
                    for document in querySnapshot!.documents {
                        
                        print("we got some documents")
            
            self.checkCalendarStatus2()
        
            let userEventStoreID = document.documentID
            
            self.getEventInformation3(eventID: eventIDChosen, userEventStoreID: userEventStoreID) { (userEventStoreID, eventSecondsFromGMT, startDates, endDates) in
                
                print("Succes getting the event data")
                
                print("startDates: \(startDates), endDates: \(endDates)")
                
                let dateFormatterTZ = DateFormatter()
                dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
                dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
                
                let numberOfDates = endDates.count - 1
                
                let startDateDate = dateFormatterTZ.date(from: startDates[0])
                let endDateDate = dateFormatterTZ.date(from: endDates[numberOfDates])
                
                let endDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).endDatesOfTheEvents
                let startDatesOfTheEvents = self.getCalendarData3(startDate: startDateDate!, endDate: endDateDate!).startDatesOfTheEvents
                
                
                
                let finalAvailabilityArray2 = self.compareTheEventTimmings3(datesBetweenChosenDatesStart: startDates, datesBetweenChosenDatesEnd: endDates, startDatesOfTheEvents: startDatesOfTheEvents, endDatesOfTheEvents: endDatesOfTheEvents)
                
                
                //                        add the finalAvailabilityArray to the userEventStore
                
                
                self.commitUserAvailbilityData(userEventStoreID: userEventStoreID, finalAvailabilityArray2: finalAvailabilityArray2)
                
                
                
                self.performSegue(withIdentifier: "issueWithArraySegue", sender: self)
                
                self.resultsResponseComplete()
                
                        }
                    }
            }
            
        
        
        
    }
    }
    

}

//extension allowing us to convert a hex colour into a colour swift can use
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


