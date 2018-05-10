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
        view.clipsToBounds = false;
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -5);
        view.layer.shadowOpacity = 0.5;
        view.layer.masksToBounds = false;
    }
    func forwardDelegate(delegate: BottomSheetDelegate) {
        self.bottomSheetViewController.delegate = delegate
    }
}
