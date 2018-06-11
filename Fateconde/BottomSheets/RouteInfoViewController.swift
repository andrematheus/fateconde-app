//
//  RouteInfoViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 10/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class RouteInfoViewController: UIViewController {
    var route: Route<Location>? = nil
    var embedParent: EmbeddedViewController? = nil
    
    @IBOutlet weak var labelDe: UILabel!
    @IBOutlet weak var labelTo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.labelDe.text = route!.from.title
        self.labelTo.text = route!.to.title
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startNavigation(_ sender: Any) {
        embedParent?.startNavigation(route!)
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
