//
//  PoiInfoViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class PoiInfoViewController: UIViewController, FatecHeaderDelegate {
    weak var embedParent: EmbeddedViewController? = nil
    
    @IBOutlet weak var header: FatecHeader!
    
    var poi: PointOfInterest? = nil {
        didSet {
            updateLabels()
        }
    }
    
    @IBOutlet weak var poiName: UILabel!
    @IBOutlet weak var poiLocalization: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        self.header.delegate = self
    }

    func updateLabels() {
        if let poi = self.poi, let poiName = self.poiName, let poiLocalization = self.poiLocalization {
            self.header.title = poi.title
            poiName.text = poi.title
            poiLocalization.text = poi.description
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func remove() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func showRouteSetup(_ sender: Any) {
        if let poi = self.poi as? Location {
            let createRoute = CreateRouteViewController(nibName: "CreateRouteViewController", bundle: nil)
            createRoute.from = poi
            embedParent?.displayCreateRoute(createRoute: createRoute)
        }
    }
    
    func closed() {
        if let vc = embedParent {
            vc.hidePoiInfo()
        }
    }
}
