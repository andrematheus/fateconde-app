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
        mainViewController?.zoomToSantiago()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleDebug(_ sender: Any) {
        mainViewController?.toggleDebug(sender)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
