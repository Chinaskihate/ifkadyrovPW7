////
////  MapViewController.swift
////  ifkadyrovPW7
////
////  Created by user211270 on 1/28/22.
////
//
//import UIKit
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections
//import MapboxMaps
//import MapboxSearchUI
//
//class MapViewController: UIViewController, NavigationMapViewDelegate, NavigationViewControllerDelegate {
//    var searchController = MapboxSearchController()
//    var annotationManager: PointAnnotationManager?
//    var coordinates: [CLLocationCoordinate2D] = []
//    var navigationMapView: NavigationMapView!
//    var navigationRouteOptions: NavigationRouteOptions!
//    var currentRouteIndex = 0 {
//        didSet {
//            showCurrentRoute()
//        }
//    }
//
//    var currentRoute: MapboxDirections.Route? {
//        return routes?[currentRouteIndex]
//    }
//
//    var routes: [MapboxDirections.Route]? {
//        return routeResponse?.routes
//    }
//
//    var routeResponse: RouteResponse? {
//        didSet {
//            guard currentRoute != nil else {
//                navigationMapView.removeRoutes()
//                return
//            }
//            currentRouteIndex = 0
//        }
//    }
//
//    func showCurrentRoute() {
//        guard let currentRoute = currentRoute else { return }
//
//        var routes = [currentRoute]
//        routes.append(contentsOf: self.routes!.filter {
//            $0 != currentRoute
//        })
//        navigationMapView.show(routes)
//        navigationMapView.showWaypoints(on: currentRoute)
//    }
//
//    // MARK: - UIViewController lifecycle methods
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        navigationMapView = NavigationMapView(frame: view.bounds)
//        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        navigationMapView.delegate = self
//        navigationMapView.userLocationStyle = .puck2D()
//
//        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
//        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
//        navigationViewportDataSource.followingMobileCamera.zoom = 13.0
//        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
//
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        navigationMapView.addGestureRecognizer(gesture)
//
//        view.addSubview(navigationMapView)
//        configureUI()
//    }
//
//    // Override layout lifecycle callback to be able to style the start button.
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//    }
//
//    @objc func tappedButton(sender: UIButton) {
//        guard let routeResponse = routeResponse, let navigationRouteOptions = navigationRouteOptions else { return }
//        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
//        let navigationService = MapboxNavigationService(routeResponse: routeResponse,
//                                                        routeIndex: currentRouteIndex,
//                                                        routeOptions: navigationRouteOptions,
//                                                        simulating: .onPoorGPS)
//        let navigationOptions = NavigationOptions(navigationService: navigationService)
//        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: currentRouteIndex,
//                                                                   routeOptions: navigationRouteOptions,
//                                                                   navigationOptions: navigationOptions)
//        navigationViewController.delegate = self
//
//        present(navigationViewController, animated: true, completion: nil)
//    }
//
//    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        guard gesture.state == .ended else { return }
//        let location = navigationMapView.mapView.mapboxMap.coordinate(for: gesture.location(in: navigationMapView.mapView))
//
//        requestRoute(destination: location)
//    }
//
//    func requestRoute(destination: CLLocationCoordinate2D) {
//        guard let userLocation = navigationMapView.mapView.location.latestLocation else { return }
//
//        let location = CLLocation(latitude: userLocation.coordinate.latitude,
//                                  longitude: userLocation.coordinate.longitude)
//
//        let userWaypoint = Waypoint(location: location,
//                                    heading: userLocation.heading,
//                                    name: "user")
//
//        let destinationWaypoint = Waypoint(coordinate: destination)
//
//        let navigationRouteOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
//
//        Directions.shared.calculate(navigationRouteOptions) { [weak self] (_, result) in
//            switch result {
//            case .failure(let error):
//                print(error.localizedDescription)
//            case .success(let response):
//                guard let self = self else { return }
//
//                self.navigationRouteOptions = navigationRouteOptions
//                self.routeResponse = response
//            }
//        }
//    }
//
//    // Delegate method called when the user selects a route
//    func navigationMapView(_ mapView: NavigationMapView, didSelect route: MapboxDirections.Route) {
//        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
//    }
//
//    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
//        dismiss(animated: true, completion: nil)
//    }
//
//
//
//    private func configureUI() {
//        configureButtonStackView()
//        configureButtons()
//        configureTextStackView()
//        configureTap()
//    }
//
//    private func configureTap() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    private func configureButtons() {
//        goButton.frame = CGRect(x: 0, y: 0, width: buttonStackView.frame.width * 0.6, height: buttonStackView.frame.height)
//        goButton.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
//        clearButton.frame = CGRect(x: 0, y: 0, width: buttonStackView.frame.width * 0.3, height: buttonStackView.frame.height)
//        clearButton.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
//    }
//
//    private func configureButtonStackView() {
//        buttonStackView.addArrangedSubview(goButton)
//        buttonStackView.addArrangedSubview(clearButton)
//
//        buttonStackView.frame = CGRect(x: view.frame.width * 0.05, y: view.frame.height * 0.85, width: view.frame.width * 0.90, height: view.frame.height * 0.075)
//        buttonStackView.spacing = view.frame.width * 0.1
//        buttonStackView.distribution = .fillEqually
//        buttonStackView.alignment = .fill
//        view.addSubview(buttonStackView)
//    }
//
//    private func configureTextStackView() {
//        textStackView.axis = .vertical
//        view.addSubview(textStackView)
//        textStackView.spacing = 10
//        textStackView.pin(to: view, [.top: 50, .left: 10, .right:10])
//        [startLocation, endLocation].forEach{textField in
//            textField.setHeight(to: 40)
//            textField.delegate = self
//            textStackView.addArrangedSubview(textField)
//        }
//    }
//
//    private let buttonStackView: UIStackView = {
//        let buttonStackView = UIStackView()
//        buttonStackView.axis = .horizontal
//        return buttonStackView
//    }()
//
//    private let goButton: CustomButton = {
//        let goButton = CustomButton(
//            backgroundColor: .systemOrange,
//            content: "GO",
//            frame: CGRect(x: 0, y: 0, width: 10, height: 30)
//        )
//        return goButton
//    }()
//
//    private let clearButton: CustomButton = {
//        let goButton = CustomButton(
//            backgroundColor: .darkGray,
//            content: "CLEAR",
//            frame: CGRect(x: 0, y: 0, width: 80, height: 30)
//        )
//        return goButton
//    }()
//
//    @objc func goButtonWasPressed() {
//        print("Looking for a route from \(startLocation.text as String?) to \(endLocation.text as String?)")
//
//        guard
//            let first = startLocation.text,
//            let second = endLocation.text,
//            first != second
//        else {
//            return
//        }
//
//        let group = DispatchGroup()
//        group.enter()
//        getCoordinateFrom(address: first, completion: { [weak self] coords, _ in
//            if let coords = coords {
//                self?.coordinates.append(coords)
//            }
//            group.leave()
//        })
//
//        group.enter()
//        getCoordinateFrom(address: second, completion: { [weak self] coords, _ in
//            if let coords = coords {
//                self?.coordinates.append(coords)
//            }
//            group.leave()
//        })
//        //            group.notify(queue: .main) {
//        //                DispatchQueue.main.async { [weak self] in
//        //                    self?.buildPath()
//        //                }
//        //            }
//        coordinates = []
//    }
//
//    @objc func clearButtonWasPressed() {
//        startLocation.text = ""
//        endLocation.text = ""
//        clearButton.setTitleColor(.gray, for: .disabled)
//        clearButton.isEnabled = false
//    }
//
//    private let textStackView: UIStackView = {
//        let control = UIStackView()
//        return control
//    }()
//
//    private let startLocation: UITextField = {
//        let control = UITextField()
//        control.backgroundColor = UIColor.lightGray
//        control.textColor = UIColor.black
//        control.placeholder = "From..."
//        control.layer.cornerRadius = 2
//        control.clipsToBounds = false
//
//        control.font = UIFont.systemFont(ofSize: 15)
//        control.borderStyle = UITextField.BorderStyle.roundedRect
//        control.autocorrectionType = UITextAutocorrectionType.yes
//        control.keyboardType = UIKeyboardType.default
//        control.returnKeyType = UIReturnKeyType.done
//        control.clearButtonMode = UITextField.ViewMode.whileEditing
//        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
//        return control
//    }()
//
//    private let endLocation: UITextField = {
//        let control = UITextField()
//        control.backgroundColor = UIColor.lightGray
//        control.textColor = UIColor.black
//        control.placeholder = "To..."
//        control.layer.cornerRadius = 2
//        control.clipsToBounds = false
//
//        control.font = UIFont.systemFont(ofSize: 15)
//        control.borderStyle = UITextField.BorderStyle.roundedRect
//        control.autocorrectionType = UITextAutocorrectionType.yes
//        control.keyboardType = UIKeyboardType.default
//        control.returnKeyType = UIReturnKeyType.done
//        control.clearButtonMode = UITextField.ViewMode.whileEditing
//        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
//        return control
//    }()
//
//    private func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
//        DispatchQueue.global(qos: .background).async {
//            CLGeocoder().geocodeAddressString(address) {
//                completion($0?.first?.location?.coordinate, $1)
//            }
//        }
//    }
//}
//
//extension MapViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if (textField == startLocation && endLocation.hasText ||
//            textField == endLocation && startLocation.hasText
//        ) {
//            goButtonWasPressed()
//        }
//        return true
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if (textField.hasText) {
//            clearButton.isEnabled = true
//        }
//    }
//}
//
//
