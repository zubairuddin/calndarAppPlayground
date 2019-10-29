//
//  SelectDateViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 20/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class SelectDateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dateChosen = ""
    var dateChosenPosition = Int()
    
    
    
    let redColour = UIColor.init(red: 255, green: 235, blue: 230)
    let greenColour = UIColor.init(red: 191, green: 241, blue: 160)
    let yellowColour = UIColor.init(red: 250, green: 219, blue: 135)
    let orangeColour = UIColor.init(red: 250, green: 200, blue: 135)

    @IBOutlet weak var selectDateTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Event Date"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
        selectDateTableView.dataSource = self
        selectDateTableView.delegate = self
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateSelected))

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = datesToChooseFrom.count - 1
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let circleItGreen = UIColor(red: 0, green: 176, blue: 156)
        
        let cell = selectDateTableView.dequeueReusableCell(withIdentifier: "chooseDateCell", for: indexPath)
        
        
        cell.textLabel?.text = ("\(datesToChooseFrom[indexPath.row + 1] as! String) (Availability: \(availabilitySummaryArray[0][indexPath.row + 1]))")
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
        
        let fraction = fractionResults[0][indexPath.row] as! Float
        
        if fraction <= 0.25{
            
            cell.backgroundColor = redColour
            
        }
        else if fraction <= 0.5{
            cell.backgroundColor = orangeColour
            
        }
        else if fraction <= 0.75{
            cell.backgroundColor = yellowColour
            
        }
        else{
            cell.backgroundColor = greenColour
            cell.layer.borderColor = circleItGreen.cgColor
            cell.layer.borderWidth = 4
            cell.layer.cornerRadius = 5
            
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        dateChosen = eventResultsArrayDetails[0][indexPath.row + 1] as! String
        
        dateChosenPosition = indexPath.row
        
        print(eventResultsArrayDetails[0][indexPath.row + 1])
        
    }
    
    
@objc func saveDateSelected() {
    
    if dateChosen == "" {
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Please choose a date"
        loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
        loadingNotification.mode = MBProgressHUDMode.customView
        loadingNotification.hide(animated: true, afterDelay: 1)
    }
    else{
    
    dbStore.collection("eventRequests").document(eventResultsArrayDetails[3][1] as! String).setData(["chosenDate" : dateChosen], merge: true)
        
        dbStore.collection("eventRequests").document(eventResultsArrayDetails[3][1] as! String).setData(["chosenDatePosition" : dateChosenPosition], merge: true)
    
    
    print("date submitted to the eventRequest table: \(dateChosen)")
    
    //            Adds the chosen date to each individuals user event store
    dbStore.collection("userEventStore").whereField("eventID", isEqualTo: eventResultsArrayDetails[3][1] as! String).getDocuments { (querySnapshot, error) in
        if error != nil {
            print("Error getting documents: \(error!)")
        }
        else {
            
            for document in querySnapshot!.documents {
                //                    print("\(document.documentID) => \(document.data())")
                
                var documentIdentifier : String
                
                documentIdentifier = document.documentID
        
                
                dbStore.collection("userEventStore").document(documentIdentifier).setData(["chosenDate" : self.dateChosen], merge: true)
                
                
                
                print("chosen dates added to the userEventStore")
            
                
            }}}
        
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let description = eventResultsArrayDetails[2][1] as! String
    let location = eventResultsArrayDetails[1][1] as! String
    let startTimeString = eventResultsArrayDetails[6][1] as! String
    let endTimeString = eventResultsArrayDetails[7][1] as! String
    let endDate = dateFormatter.date(from: "\(dateChosen) \(endTimeString)")!
    let startDate = dateFormatter.date(from: "\(dateChosen) \(startTimeString)")!
    
    performSegue(withIdentifier: "dateChosenSave", sender: Any.self)
    
//    addEventToCalendar(title: description, description: description, startDate: startDate, endDate: endDate, location: location)
    

    }
    
    
    }
