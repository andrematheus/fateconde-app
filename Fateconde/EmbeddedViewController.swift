//
//  EmbeddedViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

enum AllowedHeights {
    case minimal
    case medium
    case maximum
    
    static let all: [AllowedHeights] = [.minimal, .medium, .maximum]
}

class EmbeddedViewController: UIViewController {
    @IBOutlet var bottomSheetViewController: BottomSheetViewController!
    @IBOutlet var outerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    public weak var delegate: ViewController?
    weak var poiInfo: PoiInfoViewController?
    weak var createRoute: CreateRouteViewController?
    weak var routeInfo: RouteInfoViewController?
    
    @IBOutlet weak var bottomBorderView: UIView!
    
    var allowedHeights: [AllowedHeights] = AllowedHeights.all {
        didSet {
            delegate?.updateHeight(allowed: self.allowedHeights)
        }
    }
    
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
        
        bottomSheetViewController.tableView = self.tableView
        bottomSheetViewController.searchBar = self.searchBar
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
    
    func startNavigation(_ route: Route<Location>) {
        hideRouteInfo()
        let leg = route.locationLegs[0]
        self.delegate?.selectedPoi = leg
    }
    
    func removeSubControllers() {
        self.poiInfo?.remove()
        self.createRoute?.remove()
        self.routeInfo?.remove()
    }
    func displayCreateRoute(createRoute: CreateRouteViewController) {
        displayInfo(info: createRoute)
        createRoute.embedParent = self
        self.createRoute = createRoute
        self.allowedHeights = [.maximum]
    }
    
    func hideCreateRoute() {
        if self.createRoute != nil {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut ,animations: {
                self.createRoute?.view.frame = self.outerView.frame.offsetBy(dx: 0, dy: self.outerView.frame.height)
            }, completion: { done in
                self.createRoute?.remove()
                self.createRoute = nil
            })
        }
        self.allowedHeights = AllowedHeights.all
    }
    
    func displayPoiInfo(poiInfo: PoiInfoViewController) {
        displayInfo(info: poiInfo)
        poiInfo.embedParent = self
        self.poiInfo = poiInfo
        self.allowedHeights = [.medium, .minimal]
    }
    
    func hidePoiInfo() {
        if self.poiInfo != nil {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut ,animations: {
                self.poiInfo?.view.frame = self.outerView.frame.offsetBy(dx: 0, dy: self.outerView.frame.height)
            }, completion: { done in
                self.poiInfo?.remove()
                self.poiInfo = nil
            })
        }
        self.allowedHeights = AllowedHeights.all
    }
    
    func displayRouteInfo(routeInfo: RouteInfoViewController) {
        displayInfo(info: routeInfo)
        routeInfo.embedParent = self
        self.routeInfo = routeInfo
        self.allowedHeights = [.medium]
    }
    
    func hideRouteInfo() {
        if self.routeInfo != nil {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut ,animations: {
                self.routeInfo?.view.frame = self.outerView.frame.offsetBy(dx: 0, dy: self.outerView.frame.height)
            }, completion: { done in
                self.routeInfo?.remove()
                self.routeInfo = nil
            })
        }
        self.allowedHeights = AllowedHeights.all
    }
    
    func displayInfo(info: UIViewController) {
        removeSubControllers()
        self.addChildViewController(info)
        info.view.frame = self.outerView.frame.offsetBy(dx: 0, dy: self.outerView.frame.height)
        info.didMove(toParentViewController: self)
        self.outerView.addSubview(info.view)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut ,animations: {
            info.view.frame = self.outerView.frame
        })
    }
}
