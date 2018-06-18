//
//  DebugTableViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 01/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit

class DebugTableViewController: UITableViewController {

    weak var mainViewController: ViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func zoomToSantiago(_ sender: Any) {
        //mainViewController?.selectedPoi = AppData.sharedInstance.pointsOfInterest.locationsByCode["sa"]
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSampleRoute(_ sender: Any) {
        let app = AppData.sharedInstance
        let l1 = app.pointsOfInterest.locationsByCode["g1"]!
        let l2 = app.pointsOfInterest.locationsByCode["sa0s2"]!
        let route = app.pointsOfInterest.routes.route(from: l1, to: l2)
        if let mv = mainViewController {
            mv.selectedPoi = route?.locationLegs[mv.routeLeg] ?? app.pointsOfInterest.fatec
            mv.routeLeg += 1
            if let endIndex = route?.locationLegs.count {
                if mv.routeLeg > endIndex - 1{
                    mv.routeLeg = 0
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleDebug(_ sender: Any) {
        mainViewController?.toggleDebug(sender)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func debugAllRoutes(_ sender: Any) {
        let app = AppData.sharedInstance
        if let mv = mainViewController {
            let theRoutes = app.pointsOfInterest.routes.debugRoute(selection: mv.selectedPoi, selectedLevel: mv.selectedLevel)
            mv.selectedPoi = theRoutes
        }
    }
    @IBOutlet weak var showAllRoutes: UIButton!
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
