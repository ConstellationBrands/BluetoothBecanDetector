//
//  UserLocationServiceTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Vishal Bharam. All rights reserved.
//

import Foundation
import XCTest
import CoreLocation
@testable import BluetoothBeaconDetector

class UserLocationServiceTests: XCTestCase {

    class TestCLLocationManager: CLLocationManager {

    }

    var service: UserLocationService!
    var locationManager: TestCLLocationManager!

    override func setUp() {
        super.setUp()
        locationManager = TestCLLocationManager()
        service = UserLocationService()
        service.locationManager = locationManager
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetUserCurrentLocationImmediate() {
        service.startTracking()
        locationManager.delegate?.locationManager!(locationManager, didUpdateLocations: [CLLocation(latitude: 37.9101, longitude: 122.0652)])
        let location = service.getUserCurrentLocation()
        XCTAssertEqual(location?.coordinate.latitude, 37.9101)
        XCTAssertEqual(location?.coordinate.longitude, 122.0652)
    }

    func testGetUserCurrentLocationCallback() {
        let expectation = self.expectation(description: #function)
        service.startTracking()
        locationManager.delegate?.locationManager!(locationManager, didUpdateLocations: [CLLocation(latitude: 37.9101, longitude: 122.0652)])
        service.getUserCurrentLocation(locationCallback: {location in
            XCTAssertEqual(location.coordinate.latitude, 37.9101)
            XCTAssertEqual(location.coordinate.longitude, 122.0652)
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 1.0)
    }
}
