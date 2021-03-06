//
//  FatecHeader.swift
//  Fateconde
//
//  Created by André Roque Matheus on 10/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit

@objc protocol FatecHeaderDelegate {
    func closed()
}

class FatecHeader: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var delegate: FatecHeaderDelegate?
    @IBOutlet weak var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    var title: String = ""   {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("FatecHeader", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]        
    }
    
    @IBAction func close(_ sender: Any) {
        delegate?.closed()
    }
}
