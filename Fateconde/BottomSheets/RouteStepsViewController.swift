//
//  RouteStepsViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 13/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class RouteStepsViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var embedParent: EmbeddedViewController? = nil
    var route: Route<Location>? = nil
    var vcs: [RouteStepViewController] = []
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.view.backgroundColor = FatecColors.cinzaEscuro
    }

    override func viewWillAppear(_ animated: Bool) {
        if let route = route {
            buildViewControllers(route: route)
            setViewControllers([self.vcs[0]], direction: .forward, animated: false, completion: nil)
            embedParent?.delegate?.selectedPoi = route.locationLegs[0]
        }
    }
    
    func buildViewControllers(route: Route<Location>) {
        let legs = route.locationLegs
        var i = 0
        vcs = legs.map { leg in
            let vc = RouteStepViewController(nibName: "RouteStepViewController", bundle: nil)
            vc.leg = leg
            vc.idx = i
            vc.embedParent = self.embedParent
            i += 1
            return vc
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? RouteStepViewController {
            let index = vcs.index(of: vc)!
            if index == 0 {
                return nil
            } else {
                return vcs[index - 1]
            }
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? RouteStepViewController {
            let index = vcs.index(of: vc)!
            if index < vcs.count - 1 {
                return vcs[index + 1]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.vcs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
