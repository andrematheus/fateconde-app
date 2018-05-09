//
//  EmbeddedViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit

class EmbeddedViewController: UIViewController {

    @IBOutlet var bottomSheetViewController: BottomSheetViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func forwardDelegate(delegate: BottomSheetDelegate) {
        self.bottomSheetViewController.delegate = delegate
    }
}
