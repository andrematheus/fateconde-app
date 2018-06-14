//
//  RouteInfoViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 10/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class RouteInfoViewController: UIViewController, FatecHeaderDelegate {
    var route: Route<Location>? = nil
    var embedParent: EmbeddedViewController? = nil
    
    @IBOutlet weak var labelDe: UILabel!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var header: FatecHeader!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.header.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.header.title = "Itinerário"
        self.labelDe.text = route!.from.title
        self.labelTo.text = route!.to.title
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startNavigation(_ sender: Any) {
        let routeVC = RouteStepsViewController(nibName: "RouteStepsViewController", bundle: nil)
        routeVC.route = route!
        embedParent?.startNavigation(routeVC)
    }
    
    func closed() {
        embedParent?.hideRouteInfo()
        if let from = route?.from {
            embedParent?.delegate?.selectedPoi = from
        }
    }
    func remove() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
