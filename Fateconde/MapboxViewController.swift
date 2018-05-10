//
//  MapboxViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import Mapbox

class MapboxViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapView: MGLMapView!
    var debug = true
    
    let fatecLocation = CLLocationCoordinate2D.init(
        latitude: -23.529763733923176,
        longitude: -46.63198445446335
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Replace the string in the URL below with your custom style URL from Mapbox Studio.
        // Read more about style URLs here: https://www.mapbox.com/help/define-style-url/
        let styleURL = URL(string: "mapbox://styles/amatheus/cjh00qge7000y2ro186etomom")
        let mapView = MGLMapView(frame: view.bounds,
                                 styleURL: styleURL)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(fatecLocation, zoomLevel: 16.8107541650724, animated: false)
        mapView.setDirection(285.326971003092, animated: false)
        
        mapView.delegate = self
        view.addSubview(mapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {

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
