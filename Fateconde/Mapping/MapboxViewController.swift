//
//  MapboxViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import Mapbox
import PointOfInterest

enum MapZoomLevel: Double {
    case Surroundings = 15.0
    case Fatec = 16.75
    case Building = 17.5
    
    static let allValues: [MapZoomLevel] = [.Surroundings, .Fatec, .Building]
}

class MapboxViewController: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView?
    var debug = true
    
    let data = AppData.sharedInstance
    
    let direction = 285.326971003092
    
    var bottomInset: CGFloat = 240
    
    weak var currentAnnotation: MGLPointAnnotation? = nil
    var routeHelper: RouteMapHelper? = nil
    
    weak var viewController: ViewController? = nil
    
    var setupDone = false
    
    weak var selectedBuilding: Building? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Replace the string in the URL below with your custom style URL from Mapbox Studio.
        // Read more about style URLs here: https://www.mapbox.com/help/define-style-url/
        let styleURL = URL(string: "mapbox://styles/amatheus/cjhpbomza40yw2snryw5dsvub")
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.allowsTilting = false
        mapView?.allowsZooming = true
        mapView?.allowsRotating = false
        //mapView?.allowsScrolling = false
        mapView?.showsUserLocation = true
        mapView?.setUserTrackingMode(.followWithCourse, animated: false)
        mapView?.compassView.isHidden = true
        
        mapView?.delegate = self
        view.addSubview(mapView!)
    }
    
    func setup(with: ViewController) {
        viewController = with
    }
    
    func lookAt(poi: PointOfInterest?) {
        if setupDone {
            if let ann = currentAnnotation {
                mapView?.removeAnnotation(ann)
            }
            if let routeHelper = self.routeHelper, let style = self.mapView?.style {
                routeHelper.routeLayer.uninstall(style: style)
                self.routeHelper = nil
            }
            showLevel(0)
            selectedBuilding = nil
            if let poi = poi {
                switch poi {
                case let fatec as Fatec:
                    let helper = data.fatecHelper
                    mapView?.setCenter(fatec.point, zoomLevel: helper.zoomLevel, direction: self.direction, animated: true)
                case let surroundings as Surroundings:
                    let helper = data.surroundingsHelper
                    mapView?.setCenter(surroundings.point, zoomLevel: helper.zoomLevel, direction: self.direction, animated: true)
                case let building as Building:
                    if let helper = data.buildingHelpers[building.code],
                        let outline = helper.outlineLayer as? OutlineLayer {
                        let features = [outline.feature]
                        mapView?.showAnnotations(features, edgePadding: .zero, animated: true)
                    }
                    selectedBuilding = building
                case let location as Location:
                    if let building = data.pointsOfInterest.buildingsByCode[location.id.buildingCode] {
                        lookAt(poi: building)
                    }
                    if let nameLayer = data.locationHelpers[location.id.code]?.nameLayer as? NameLayer {
                        let ann = nameLayer.pointFeature
                        mapView?.addAnnotation(ann)
                        currentAnnotation = ann
                    }
                case let route as Route<Location>:
                    let routeHelper = data.routeHelper(withRoute: route)
                    let layer = routeHelper.routeLayer
                    if let mapView = self.mapView, let style = mapView.style {
                        layer.install(style: style)
                        mapView.showAnnotations([layer.feature], animated: true)
                    }
                    self.routeHelper = routeHelper
                case let leg as LocationRouteLeg:
                    let routeLegHelper = data.routeHelper(withLeg: leg)
                    let layer = routeLegHelper.routeLayer
                    if let mapView = self.mapView, let style = mapView.style {
                        layer.install(style: style)
                        mapView.showAnnotations([layer.feature], animated: true)
                    }
                    self.routeHelper = routeLegHelper
                default:
                    print("Unknown poi: \(poi)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        mapView.direction = self.direction
        drawFeatures(style)
        setupDone = true
        if let poi = viewController?.selectedPoi {
            lookAt(poi: poi)
        }
    }
    
    func drawFeatures(_ style: MGLStyle) {
        data.fatecHelper.imageLayer.install(style: style)
        //data.fatecHelper.outlineLayer.install(style: style)
        data.fatecHelper.nameLayer.install(style: style)
        
        for bh in data.buildingHelpers.values {
            for (k,pl) in bh.planLayers {
                pl.install(style: style)
                if k > 0 {
                    pl.hide()
                }
            }
        }
        for bh in data.buildingHelpers.values {
            bh.outlineLayer.install(style: style)
        }
        for bh in data.buildingHelpers.values {
            bh.nameLayer.install(style: style)
        }
        
        for l in data.locationHelpers.values {
            l.nameLayer.install(style: style)
            if l.location.id.buildingLevel > 0 {
                l.nameLayer.hide()
            }
        }
    }
    
    func showLevel(_ level: Int) {
        if let sb = selectedBuilding {
            if let h = data.buildingHelpers[sb.code] {
                for l in sb.levels {
                    if l == level {
                        h.planLayers[l]?.show()
                    } else {
                        h.planLayers[l]?.hide()
                    }
                }
            }
            for l in data.locationHelpers.values {
                if let b = l.location.building {
                    if b == sb && l.location.id.buildingLevel == level {
                        l.nameLayer.show()
                    } else {
                        l.nameLayer.hide()
                    }
                } else {
                    l.nameLayer.hide()
                }
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        if debug {
            print(mapView.centerCoordinate)
            print(mapView.direction)
            print(mapView.zoomLevel)
        }
    }

    
    func toggleDebug() {
        self.debug = !self.debug
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
