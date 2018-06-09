//
//  PoiInfoViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit

class PoiInfoViewController: UIViewController {
    weak var embedParent: EmbeddedViewController? = nil
    
    @IBOutlet weak var poiName: UILabel!
    @IBOutlet weak var poiLocalization: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeInfo(_ sender: Any) {
        if let vc = embedParent {
            vc.hidePoiInfo()
        }
    }
    
    func remove() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func showRouteSetup(_ sender: Any) {
    }
    
}
