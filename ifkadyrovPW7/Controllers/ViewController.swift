//
//  ViewController.swift
//  ifkadyrovPW7
//
//  Created by user211270 on 1/26/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapView)
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight : CGFloat = view.frame.size.height
        
        mapView.frame = CGRect(x:leftMargin, y:topMargin, width: mapWidth, height: mapHeight)
        
        configureUI()
        
    }
    
    private let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private func configureUI() {
    }
}

