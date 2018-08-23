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
    var centralManager: TestCBCentralManager!

    class TestJsonService: JSONService {
        override func sendData(url: String, withData params: [String : Any], completionHandler: @escaping (([String : Any]?) -> Void)) {
            completionHandler(nil)
        }
    }

    class TestUserLocationService: UserLocationService {
        public var startedTracking = true
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
        public var startedScanning = false
        public var stoppedScanning = false

        override func stopScan() {
            stoppedScanning = true
        }
        override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
            startedScanning = true
        }
    }

    override func setUp() {
        super.setUp()
        jsonService = TestJsonService()
        locationService = TestUserLocationService()
        bluetooth = Bluetooth(userLocationService: locationService)
        centralManager = TestCBCentralManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testItStartedTrakingLocation() {
        XCTAssertTrue(locationService.startedTracking)
    }

    func testThatItStartScanningForBeacons() {
        bluetooth.centralManager = centralManager
        bluetooth.startScan()
        XCTAssertTrue(centralManager.startedScanning)
    }

    func testItStopsScanningWhenRequested() {
        bluetooth.centralManager = centralManager
        bluetooth.stopScan()
        XCTAssertTrue(centralManager.stoppedScanning)
    }

    func testThatItSetsCorrectLocation() {
        XCTAssertEqual(bluetooth.currLocation?.coordinate.latitude, 37.9101)
        XCTAssertEqual(bluetooth.currLocation?.coordinate.longitude, 122.0652)
    }
}
