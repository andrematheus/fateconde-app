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
    case Building = 17.0
    
    static let allValues: [MapZoomLevel] = [.Surroundings, .Fatec, .Building]
}

class MapboxViewController: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView?
    var debug = true
    
    let data = AppData.sharedInstance
    
    let fatecLocation = CLLocationCoordinate2D.init(
        latitude: -23.529397679087438,
        longitude: -46.632665554213531
    )
    let direction = 285.326971003092
    let zoomLevel = 16.75
    let surroundingsZoomLevel = 15.0
    
    var bottomInset: CGFloat = 240
    
    weak var currentAnnotation: MGLPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Replace the string in the URL below with your custom style URL from Mapbox Studio.
        // Read more about style URLs here: https://www.mapbox.com/help/define-style-url/
        let styleURL = URL(string: "mapbox://styles/amatheus/cjhpbomza40yw2snryw5dsvub")
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.allowsTilting = false
        mapView?.allowsZooming = false
        mapView?.allowsRotating = false
        //mapView?.allowsScrolling = false
        mapView?.showsUserLocation = true
        mapView?.setUserTrackingMode(.followWithCourse, animated: false)
        mapView?.compassView.isHidden = true
        
        mapView?.delegate = self
        view.addSubview(mapView!)
    }
    
    func updateInsets(bottom: CGFloat) {
    
    }

    func lookAtFatec() {
        mapView?.setCenter(fatecLocation, zoomLevel: zoomLevel, direction: self.direction, animated: true)
    }
    
    func lookAtSurroundings() {
        mapView?.setCenter(fatecLocation, zoomLevel: surroundingsZoomLevel, direction: self.direction, animated: true)
    }
    
    func zoomToSantiago() {
        if let santiago = data.pointsOfInterest.buildingsByCode["sa"] {
            zoomToBuilding(building: santiago)
            if let bh = data.buildingHelpers["sa"],
                let l = bh.outlineLayer as? OutlineLayer {
                l.strokeLayer.lineWidth = NSExpression(forConstantValue: 5.0)
            }
        }
    }
    
    func zoomToBuilding(building: Building) {
        if let b = data.buildingHelpers[building.code],
            let outline = b.outlineLayer as? OutlineLayer {
            let features = [outline.feature]
            mapView?.showAnnotations(features, edgePadding: .zero, animated: true)
        }
    }
    
    func zoomToLocation(location: Location) {
        if let l = data.locationHelpers[location.id.code],
            let nameLayer = l.nameLayer as? NameLayer {
            let building = data.pointsOfInterest.buildingsByCode[location.id.buildingCode]!
            zoomToBuilding(building: building)
            if let ann = currentAnnotation {
                mapView?.removeAnnotation(ann)
            }
            let ann =  nameLayer.pointFeature
            mapView?.addAnnotation(ann)
            currentAnnotation = ann
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        lookAtFatec()
        drawFeatures(style)
    }
    
    func drawFeatures(_ style: MGLStyle) {
        data.fatecHelper.imageLayer.install(style: style)
        data.fatecHelper.outlineLayer.install(style: style)
        data.fatecHelper.nameLayer.install(style: style)
        
        for bh in data.buildingHelpers.values {
            for pl in bh.planLayers.values {
                pl.install(style: style)
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
