//
//  LocationService.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import CoreLocation

@Observable // Makes it trackable in real-time by the view models
class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.requestWhenInUseAuthorization()
        
        
        locationManager.startUpdatingLocation()
    }
    
    // This delegate fires automatically every time the device updates its location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filter out old, cached locations the phone remembered from earlier
        let age = location.timestamp.timeIntervalSinceNow
        if abs(age) < 15 { // Only accept locations calculated in the last 15 seconds
            self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("GPS hardware error: \(error.localizedDescription)")
    }
}
