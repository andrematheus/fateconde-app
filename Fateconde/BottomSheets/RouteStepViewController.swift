//
//  RouteStepViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 13/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class RouteStepViewController: UIViewController {
    var embedParent: EmbeddedViewController? = nil
    var leg: LocationRouteLeg? = nil
    var colors = [
        FatecColors.vermelho,
        FatecColors.destaque,
        FatecColors.cinzaMedio
    ]
    var idx: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let idx = idx {
            self.view.backgroundColor = colors[idx]
        }
        print("Foda-se!")
        self.embedParent?.delegate?.selectedPoi = leg!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
