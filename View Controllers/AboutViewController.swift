//
//  AboutViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 07/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    
    var aboutList = ["Privacy Policy"]
    
    var aboutDetailsList = ["View our privacy and data policy"]
    
    var segueList = ["privacyPolicySegue","",""]


    
    @IBOutlet var aboutTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    
        self.title = "About Circle"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
//        setup tableview
        aboutTableView.delegate = self
        
        aboutTableView.dataSource = self
        aboutTableView.rowHeight = 100
        
        
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = aboutList.count
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = aboutTableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
        
        
        cell.textLabel?.text = aboutList[indexPath.row]
        
        cell.detailTextLabel?.text = aboutDetailsList[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if segueList[indexPath.row] == ""{
            
            print("The select row has no segue \(indexPath.row)")
            
            aboutTableView.deselectRow(at: indexPath, animated: true)
            
        }
        else{
        
            performSegue(withIdentifier: segueList[indexPath.row], sender: Any.self)
            aboutTableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    

    
}
