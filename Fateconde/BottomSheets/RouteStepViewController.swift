//
//  RouteStepViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 13/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class RouteStepViewController: UIViewController, FatecHeaderDelegate {
    var embedParent: EmbeddedViewController? = nil
    var leg: LocationRouteLeg? = nil
    var isLast: Bool = false

    @IBOutlet weak var legLabel: UILabel!
    @IBOutlet weak var header: FatecHeader!
    @IBOutlet weak var finalizarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var finalizar: UIButton!
    var idx: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.header.contentView.backgroundColor = FatecColors.cinzaEscuro
        self.header.titleLabel.textColor = UIColor.white
        self.header.closeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.header.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isLast {
            self.finalizar.isHidden = true
            self.finalizarHeight.constant = 0
        }
        if let leg = leg {
            self.header.title = leg.title
            switch leg.to.type {
            case .Access:
                self.legLabel.text = "Dirija-se a \(leg.to.title) do \(leg.to.building!.title)."
            default:
                self.legLabel.text = "Dirija-se a \(leg.to.title) no \(leg.to.building!.title)."
            }
        }
        self.embedParent?.delegate?.selectedPoi = leg!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func finalizar(_ sender: Any) {
        self.closed()
    }
    
    func closed() {
        if let leg = leg {
            self.embedParent?.hideNavigation()
            if leg.to.type.visibleInMap {
                self.embedParent?.delegate?.selectedPoi = leg.to
            } else {
                self.embedParent?.delegate?.selectedPoi = leg.to.building!
            }
        }
    }
}
