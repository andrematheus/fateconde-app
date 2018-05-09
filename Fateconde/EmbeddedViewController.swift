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
    
    func forwardDelegate(delegate: BottomSheetDelegate) {
        self.bottomSheetViewController.delegate = delegate
    }
}
