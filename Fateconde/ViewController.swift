//
//  ViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BottomSheetDelegate {
    @IBOutlet weak var bottomSheetHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSheet: UIView!
    var mapController: MapboxViewController?
    let bottomSheetSmall: CGFloat = 66
    let bottomSheetMedium: CGFloat = 240
    var bottomSheetLarge: CGFloat {
        get {
            return self.view.frame.height - 50
        }
    }
    
    @IBAction func toggleDebug(_ sender: Any) {
        mapController?.toggleDebug()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let locationController = destination as? EmbeddedViewController {
            locationController.delegate = self
            locationController.forwardDelegate(delegate: self)
        } else if let mapController = destination as? MapboxViewController {
            self.mapController = mapController
        }
    }
    
    func growBottomSheet() {
        if self.bottomSheetHeight.constant == bottomSheetMedium {
            self.animateBottomSheetHeight(newHeight: bottomSheetLarge)
        } else if self.bottomSheetHeight.constant == bottomSheetSmall {
            self.animateBottomSheetHeight(newHeight: bottomSheetMedium)
        }
    }
    
    func shrinkBottomSheet() {
        if self.bottomSheetHeight.constant == bottomSheetLarge {
            self.animateBottomSheetHeight(newHeight: bottomSheetMedium)
        } else if self.bottomSheetHeight.constant == bottomSheetMedium {
            self.animateBottomSheetHeight(newHeight: bottomSheetSmall)
        }
    }
    
    private func animateBottomSheetHeight(newHeight: CGFloat) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.bottomSheetHeight.constant = newHeight
            self.view.layoutIfNeeded()
        })
    }
}

