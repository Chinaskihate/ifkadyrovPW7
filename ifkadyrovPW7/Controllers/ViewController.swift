//
//  ViewController.swift
//  ifkadyrovPW7
//
//  Created by user211270 on 1/26/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
    
    var coordinates: [CLLocationCoordinate2D] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
        configureMapView()
        configureButtonStackView()
        configureButtons()
        configureTextStackView()
        
        configureTap()
    }
    
    private func configureTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureButtons() {
        goButton.frame = CGRect(x: 0, y: 0, width: buttonStackView.frame.width * 0.6, height: buttonStackView.frame.height)
        goButton.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: buttonStackView.frame.width * 0.3, height: buttonStackView.frame.height)
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
    }
    
    private func configureMapView() {
        self.view.addSubview(mapView)
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight : CGFloat = view.frame.size.height
        
        mapView.frame = CGRect(x:leftMargin, y:topMargin, width: mapWidth, height: mapHeight)
    }
    
    private func configureButtonStackView() {
        buttonStackView.addArrangedSubview(goButton)
        buttonStackView.addArrangedSubview(clearButton)
        
        buttonStackView.frame = CGRect(x: view.frame.width * 0.05, y: view.frame.height * 0.85, width: view.frame.width * 0.90, height: view.frame.height * 0.075)
        buttonStackView.spacing = view.frame.width * 0.1
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .fill
        view.addSubview(buttonStackView)
    }
    
    private func configureTextStackView() {
        textStackView.axis = .vertical
        view.addSubview(textStackView)
        textStackView.spacing = 10
        textStackView.pin(to: view, [.top: 50, .left: 10, .right:10])
        [startLocation, endLocation].forEach{textField in
            textField.setHeight(to: 40)
            textField.delegate = self
            textStackView.addArrangedSubview(textField)
        }
    }
    
    private let buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        return buttonStackView
    }()
    
    private let goButton: CustomButton = {
        let goButton = CustomButton(
            backgroundColor: .systemOrange,
            content: "GO",
            frame: CGRect(x: 0, y: 0, width: 10, height: 30)
        )
        return goButton
    }()
    
    private let clearButton: CustomButton = {
        let goButton = CustomButton(
            backgroundColor: .darkGray,
            content: "CLEAR",
            frame: CGRect(x: 0, y: 0, width: 80, height: 30)
        )
        return goButton
    }()
    
    @objc func goButtonWasPressed() {
        print("Looking for a route from \(startLocation.text as String?) to \(endLocation.text as String?)")
        
        guard
            let first = startLocation.text,
            let second = endLocation.text,
            first != second
        else {
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        getCoordinateFrom(address: first, completion: { [weak self] coords, _ in
            if let coords = coords {
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        
        group.enter()
        getCoordinateFrom(address: second, completion: { [weak self] coords, _ in
            if let coords = coords {
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        group.notify(queue: .main) {
            DispatchQueue.main.async { [weak self] in
                self?.buildPath()
            }
        }
        coordinates = []
    }
    
    private func buildPath() {
        if (coordinates.count != 2) {
            print("Coordinates parsing error")
            return
        }
        print("From: long - \(coordinates[0].longitude), lat - \(coordinates[0].latitude)")
        print("To: long - \(coordinates[1].longitude), lat - \(coordinates[1].latitude)")
        let fromPlaceMark = MKPlacemark(coordinate: coordinates[0])
        let toPlaceMark = MKPlacemark(coordinate: coordinates[1])
        
        let fromItem = MKMapItem(placemark: fromPlaceMark)
        let toItem = MKMapItem(placemark: toPlaceMark)
        
        let request = MKDirections.Request()
        request.source = fromItem
        request.destination = toItem
        request.transportType = .automobile
        
        //request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Something is wrong! Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .systemOrange
        render.lineWidth = 5.0
        return render
    }
    
    @objc func clearButtonWasPressed() {
        startLocation.text = ""
        endLocation.text = ""
        clearButton.setTitleColor(.gray, for: .disabled)
        clearButton.isEnabled = false
        for overlay:MKOverlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
    }
    
    private let textStackView: UIStackView = {
        let control = UIStackView()
        return control
    }()
    
    private let startLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = UIColor.lightGray
        control.textColor = UIColor.black
        control.placeholder = "From..."
        control.layer.cornerRadius = 2
        control.clipsToBounds = false
        
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode = UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    private let endLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = UIColor.lightGray
        control.textColor = UIColor.black
        control.placeholder = "To..."
        control.layer.cornerRadius = 2
        control.clipsToBounds = false
        
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode = UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    private func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address) {
                completion($0?.first?.location?.coordinate, $1)
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField == startLocation && endLocation.hasText ||
            textField == endLocation && startLocation.hasText
        ) {
            goButtonWasPressed()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.hasText) {
            clearButton.isEnabled = true
        }
    }
}
