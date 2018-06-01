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
        for building in data.buildingOutlines {
            if building.building.code == "sa" {
                let santiago = building.features
                mapView?.showAnnotations(santiago, animated: true)
            }
        }
    }
    
    func zoomToBuilding(building: Building) {
        for b in data.buildingOutlines {
            if b.building.code == building.code {
                let santiago = b.features
                mapView?.showAnnotations(santiago, edgePadding: .init(top: -50.0, left: -50.0, bottom: -50.0, right: -50.0), animated: true)
            }
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
        for building in data.buildingOutlines {
            let source = MGLShapeSource(identifier: "fatec-building-outline-\(building.building.code)", features: building.features, options: nil)
            style.addSource(source)
            
            let fillLayer = MGLFillStyleLayer(identifier: "fatec-building-fill-\(building.building.code)-layer", source: source)
            fillLayer.fillColor = NSExpression(forConstantValue: building.fillLayerAttributes.fillColor)
            style.addLayer(fillLayer)
            
            let strokeLayer = MGLLineStyleLayer(identifier: "fatec-building-outline-\(building.building.code)-layer", source: source)
            strokeLayer.lineColor = NSExpression(forConstantValue: building.lineLayerAttributes.lineColor)
            strokeLayer.lineWidth = NSExpression(forConstantValue: building.lineLayerAttributes.lineWidth)
            style.addLayer(strokeLayer)
        }
        for building in data.buildingPoints {
            let source = MGLShapeSource(identifier: "fatec-building-name-\(building.building.code)", features: building.features, options: nil)
            style.addSource(source)
            
            let symbolLayer = MGLSymbolStyleLayer(identifier: "fatec-building-name-\(building.building.code)-layer", source: source)
            symbolLayer.text = NSExpression(forConstantValue: building.building.point.properties["name"])
            symbolLayer.textAllowsOverlap = NSExpression(forConstantValue: true)
            symbolLayer.textFontSize = NSExpression(forConstantValue: 12)
            style.addLayer(symbolLayer)
        }
        for building in data.pointsOfInterest.allBuildings() {
            if let planImage = building.planImage {
                let coords = building.outline.geometry.coordinates.coordinates()
                let quad = MGLCoordinateQuad(
                    topLeft: coords[0],
                    bottomLeft: coords[3],
                    bottomRight: coords[2],
                    topRight: coords[1]
                )
                let source = MGLImageSource(identifier: "plan-image-\(building.code)", coordinateQuad: quad, image: planImage)
                style.addSource(source)
                let layer = MGLRasterStyleLayer(identifier: "plan-image-\(building.code)-layer", source: source)
                layer.rasterOpacity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                   [16.75: 0, 17: 1])
                style.addLayer(layer)
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
