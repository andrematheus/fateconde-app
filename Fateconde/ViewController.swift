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
    
    @IBAction func toggleDebug(_ sender: Any) {
        mapController?.toggleDebug()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let locationController = destination as? EmbeddedViewController {
            locationController.forwardDelegate(delegate: self)
        } else if let mapController = destination as? MapboxViewController {
            self.mapController = mapController
        }
    }
    
    func growBottomSheet() {
        if self.bottomSheetHeight.constant == 240 {
            self.animateBottomSheetHeight(newHeight: 400)
        } else if self.bottomSheetHeight.constant == 400 {
            self.animateBottomSheetHeight(newHeight: 600)
        } else if self.bottomSheetHeight.constant == 100 {
            self.animateBottomSheetHeight(newHeight: 240)
        }
    }
    
    func shrinkBottomSheet() {
        if self.bottomSheetHeight.constant == 400 {
            self.animateBottomSheetHeight(newHeight: 240)
        } else if self.bottomSheetHeight.constant == 240 {
            self.animateBottomSheetHeight(newHeight: 100)
        } else if self.bottomSheetHeight.constant == 600 {
            self.animateBottomSheetHeight(newHeight: 400)
        }
    }
    
    private func animateBottomSheetHeight(newHeight: Int) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.bottomSheetHeight.constant = CGFloat(newHeight)
            self.view.layoutIfNeeded()
            self.mapController?.updateInsets(bottom: newHeight)
        })
    }
}

