//
//  BeaconTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Saranya Jayaseelan. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BluetoothBeaconDetector

class BeaconTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatItgetsCorrectSerialNumber() {
        var serialNumber = Beacon.getSerialNumber(foradvertisementData: [:])
        XCTAssertNil(serialNumber)

        let data: [String: Any] = ["kCBAdvDataManufacturerData" : Data(bytes: [0x01, 0x01, 0x01, 0x00, 0xd0, 0x00, 0x00, 0x01, 0xc2, 0x9d])]
        serialNumber = Beacon.getSerialNumber(foradvertisementData: data)
        XCTAssertNotNil(serialNumber)
        XCTAssertEqual(serialNumber, "10d00")
    }
}
