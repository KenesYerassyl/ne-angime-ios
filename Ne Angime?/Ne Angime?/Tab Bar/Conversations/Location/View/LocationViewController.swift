//
//  LocationViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 4/11/21.
//

import SnapKit
import MapKit


class LocationViewController: UIViewController {
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMapView()
        checkLocationServices()
    }
    
    private func updateMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.bottom.equalTo(view)
            make.top.equalTo(view)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
        }
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // TODO: Show alert letting the user know they have to turn this on.
        }
    }
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            print("damn")
        case .denied: // Show alert telling users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: // Show an alert letting them know what’s up
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
}
