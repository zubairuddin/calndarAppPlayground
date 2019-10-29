//
//  ManualAvailabilityViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 21/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import Instructions

var currentUsersAvailability = [Int]()

class ManualAvailabilityViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    

    
    
    
    
    @IBOutlet weak var availabilityCollectionView: UICollectionView!
    
    
    var temporaryCurrentUsersAvailability = [Int]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        availabilityCollectionView.delegate = self
        availabilityCollectionView.dataSource = self
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
        
        
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
        
        
        temporaryCurrentUsersAvailability = currentUsersAvailability
        print("temporaryCurrentUsersAvailability: \(temporaryCurrentUsersAvailability)")
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAvailability))
        
                
    }
    
    
    @objc func saveAvailability() {
        
        commitUserAvailbilityData(userEventStoreID: currentUserAvailabilityDocID, finalAvailabilityArray2: temporaryCurrentUsersAvailability)
        
        
        performSegue(withIdentifier: "availabilitySaved", sender: Any.self)
        
        
    }
    

//    number of rows
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let numberOfRows = temporaryCurrentUsersAvailability.count
        print("numberOfRows: \(numberOfRows)")
        
        return numberOfRows
    }
    
    
    //    number of columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        

        
         return 2
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = availabilityCollectionView.dequeueReusableCell(withReuseIdentifier: "availabilityCell", for: indexPath) as? AvailabilityCollectionViewCell else{
            
            print("could not deque the cell")
            return UICollectionViewCell()
            
            
        }
        
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
//        set the first column equal to the dates
        if indexPath.row == 1{
            
            cell.collectionViewLabel.text = arrayForEventResultsPageFinal[0][indexPath.section + 1] as? String
            
            cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 15)
            
//            cell.collectionViewLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            
                    cell.backgroundColor = UIColor.clear
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor

        }
        
        if indexPath.row == 0{
            
            
            let redColour = UIColor.init(red: 255, green: 235, blue: 230)
            let greenColour = UIColor.init(red: 191, green: 241, blue: 160)
            
            if temporaryCurrentUsersAvailability[indexPath.section] == 0 {
                
                
                cell.collectionViewLabel.text = " ❌   "
                
                cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 15)
//                cell.collectionViewLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
                cell.collectionViewLabel.textAlignment = .center
                cell.backgroundColor = redColour
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor.darkGray.cgColor


            }
            if temporaryCurrentUsersAvailability[indexPath.section] == 1 {
                
                cell.collectionViewLabel.text = " ✔️   "
                cell.backgroundColor = greenColour
                
                cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 15)
//                cell.collectionViewLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
                cell.collectionViewLabel.textAlignment = .center
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor.darkGray.cgColor

                
            }
            if temporaryCurrentUsersAvailability[indexPath.section] == 10{
            
                cell.collectionViewLabel.font = UIFont(name: "Helvetica Neue", size: 20)
            cell.collectionViewLabel.text = "  ？ "
//                cell.collectionViewLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
                
            cell.backgroundColor = UIColor.lightGray
                
    
//            cell.collectionViewLabel.textAlignment = .center
                
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.darkGray.cgColor

                
                
            }
        }

        return cell
     }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.row == 1{
         return CGSize(width: 200 , height: 50)
        }
        else{
            return CGSize(width: 50 , height: 50)
        }


        }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("User Selected: row: \(indexPath.row) section: \(indexPath.section)")
        
        if temporaryCurrentUsersAvailability[indexPath.section] == 0{
            print("Currently unavailable")
            
           temporaryCurrentUsersAvailability[indexPath.section] = 1
            
            availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
            availabilityCollectionView.reloadData()
            
        }
        else if temporaryCurrentUsersAvailability[indexPath.section] == 1{
            print("Currently available")
            
            temporaryCurrentUsersAvailability[indexPath.section] = 10
            availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
            availabilityCollectionView.reloadData()
            
        }
        else if temporaryCurrentUsersAvailability[indexPath.section] == 10{
            
            print("Currently not responded")
            
            temporaryCurrentUsersAvailability[indexPath.section] = 0
            availabilityCollectionView.deselectItem(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
            availabilityCollectionView.reloadData()
            
        }
        print("temporaryCurrentUsersAvailability: \(temporaryCurrentUsersAvailability)")
        availabilityCollectionView.reloadData()
        
        
    }
    
    //    Defines where the coachmark will appear
    var pointOfInterest = UIView()
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        

        let hintLabels = ["Select each date to change it's availability, press save when finished"]
        
        let nextlabels = ["OK"]
        
        coachViews.bodyView.hintLabel.text = hintLabels[index]
        
        coachViews.bodyView.nextLabel.text = nextlabels[index]
//        coachViews.bodyView.nextLabel.isEnabled = false
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
    }
    
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        
        let hintPositions = [CGRect(x: screenWidth/2 - 150, y: 150, width: 40, height: 40)]
        
        pointOfInterest.frame = hintPositions[index]
        
        return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
    }
    
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        
        return 1
        
    }
    
        //    The coach marks must be called from the viewDidAppear and not the ViewDidLoad.
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            let manualEditCoachMarksCount = UserDefaults.standard.integer(forKey: "manualEditCoachMarksCount")
            let createEventCoachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
            
            print("manualEditCoachMarksCount \(manualEditCoachMarksCount)")
            
            
            if manualEditCoachMarksCount < 4 || createEventCoachMarksPermenant == true{
            
            coachMarksController.start(in: .window(over: self))
                
                UserDefaults.standard.set(manualEditCoachMarksCount + 1, forKey: "manualEditCoachMarksCount")
                
            }
            else{
                
            }
        }
        
        
        
    //    The view coachmarks should be removed once the view is removed
        override func viewWillDisappear( _ animated: Bool) {
            super.viewWillDisappear(animated)

            self.coachMarksController.stop(immediately: true)
        }
        

        let coachMarksController = CoachMarksController()

}
