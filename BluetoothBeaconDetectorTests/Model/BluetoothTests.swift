//
//  BluetoothTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Saranya Jayaseelan. All rights reserved.
//

import XCTest
import CoreLocation
@testable import BluetoothBeaconDetector

class BluetoothTests: XCTestCase {
    var bluetooth: Bluetooth!

    class TestJsonService: JSONService {
        override func sendData(url: String, withData params: [String : Any], completionHandler: @escaping (([String : Any]?) -> Void)) {
            completionHandler(nil)
        }

        override func getData(url: String, completionHandler: @escaping (([String : Any]?) -> Void)) {
            completionHandler(nil)
        }
    }

    class TestUserLocationService: UserLocationService {
        public var startedTracking = false
        public var stoppedTracking = false

        override func getUserCurrentLocation() -> CLLocation? {
            if self.locationManager != nil {
                return testLocation()
            }
            return nil
        }

        override func getUserCurrentLocation(locationCallback: @escaping UserLocationCallback) {
            locationCallback(testLocation())
        }

        private func testLocation() -> CLLocation {
            return CLLocation(latitude: 37.9101, longitude: 122.0652)
        }

        override func startTracking() {
            startedTracking = true
        }

        override func stopTracking() {
            stoppedTracking = true
        }
    }

    override func setUp() {
        super.setUp()
        bluetooth = Bluetooth()
        bluetooth.dataManager = TestJsonService()
        bluetooth.userLocationService =  TestUserLocationService()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testThatItStartScanningForBeacon() {
    }
}
