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
        latitude: -23.529721293549812,
        longitude: -46.632170188996383
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.styleURL = URL(string: "mapbox://styles/amatheus/cj9rqxjni1cem2ss03r7y2k73")
        mapView.setCenter(fatecLocation, zoomLevel: 16.9379328310557, animated: false)
        mapView.setDirection(287.519907198647, animated: false)
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
