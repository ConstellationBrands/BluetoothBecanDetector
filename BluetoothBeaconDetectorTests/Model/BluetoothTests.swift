//
//  BluetoothTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Saranya Jayaseelan. All rights reserved.
//

import XCTest
import CoreLocation
import CoreBluetooth
@testable import BluetoothBeaconDetector

class BluetoothTests: XCTestCase {
    var bluetooth: Bluetooth!
    var jsonService: TestJsonService!
    var locationService: TestUserLocationService!
    var centralManager: CBCentralManager!

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
            return testLocation()
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

    class TestCBCentralManager: CBCentralManager {
        override func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
            return []
        }
    }

    override func setUp() {
        super.setUp()
        bluetooth = Bluetooth()
        jsonService = TestJsonService()
        locationService = TestUserLocationService()
        bluetooth.dataManager = jsonService
        bluetooth.userLocationService = locationService

        centralManager = TestCBCentralManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
