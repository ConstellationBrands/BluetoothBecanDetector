//
//  UserLocationService.swift
//  CBI Radar
//
//  Created by Vishal Bharam on 7/5/18.
//  Copyright © 2018 Vik Denic. All rights reserved.
//

import Foundation
import CoreLocation

public typealias UserLocationCallback = ((CLLocation) -> Void)

public class UserLocationService: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var userCurrentLocation: CLLocation?
    var callback: UserLocationCallback?

    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    public func getUserCurrentLocation() -> CLLocation? {
        return userCurrentLocation
    }

    public func getUserCurrentLocation(locationCallback: @escaping UserLocationCallback) {
        if let location = self.userCurrentLocation {
            locationCallback(location)
        } else {
            callback = locationCallback
        }
    }

    public func startTracking() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    public func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            userCurrentLocation = currentLocation
            if let callback = self.callback {
                callback(currentLocation)
                self.callback = nil
            }
        }
    }
}
