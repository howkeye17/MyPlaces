//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Valera Vasilevich on 10.06.21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupPlacemark()
        checkLocationServices()
        
    }
    
    
    @IBAction func centerViewInUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            locationManagerDidChangeAuthorization(locationManager)
            // checkLocationAutorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    private func setupLocationManager() {
        //  locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { // вместо checkLocationAutorization!
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case . denied:
            // show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On") }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On") }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print ("New case is availible")
        }
    }
    
    private func showAlert (title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    /*
     private func checkLocationAutorization() {
     switch CLLocationManager.authorizationStatus() {  -- устарело после iOS 14 и новее
     case .authorizedWhenInUse:
     mapView.showsUserLocation = true
     break
     case . denied:
     // show alert controller
     break
     case .notDetermined:
     locationManager.requestWhenInUseAuthorization()
     break
     case .restricted:
     // show alert controller
     break
     case .authorizedAlways:
     break
     @unknown default:
     print ("New case is availible")
     }
     }
     */
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}

//extension MapViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        setupLocationManager()
//    }
//}
