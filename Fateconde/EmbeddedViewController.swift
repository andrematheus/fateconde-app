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
    public weak var delegate: ViewController?
    
    override func viewDidLoad() {
        view.clipsToBounds = false;
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2);
        view.layer.shadowOpacity = 0.15;
        view.layer.masksToBounds = false;
        
        //view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(panGesture)
    }
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        /*
        let location = sender.location(in: view)
        let translation = sender.translation(in: view)
        */
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            
        } else if sender.state == .changed {
            
        } else if sender.state == .ended {
            if velocity.y < 0 {
                self.delegate?.growBottomSheet()
            } else {
                self.delegate?.shrinkBottomSheet()
            }
        }
    }
    
    func forwardDelegate(delegate: BottomSheetDelegate) {
        self.bottomSheetViewController.delegate = delegate
    }
}
