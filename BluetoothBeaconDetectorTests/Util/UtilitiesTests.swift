//
//  UtilitiesTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Saranya Jayaseelan. All rights reserved.
//

import Foundation
import XCTest
import CoreBluetooth
@testable import BluetoothBeaconDetector


class UtilitiesTests: XCTestCase {
    let utilities = Utilities()
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatItConvertEmptyAdvDataToSuccessfully() {
        let advData: [String: Any] = [:]
        XCTAssertEqual(utilities.byteDataToHexString(advData), nil)
    }

    func testThatItSuccessfullyConvertAdvDataToBeaconCode() {
        let data: [CBUUID: Data?] = [CBUUID(string:"FE33") : Data(bytes: [0x01, 0x01, 0x01, 0x00, 0xd0, 0x00, 0x00, 0x01, 0xc2, 0x9d]), CBUUID(string:"FE65"): Data(bytes: [0x01])]
        let advData: [String: Any] = ["kCBAdvDataServiceData" : data]
        XCTAssertEqual(utilities.byteDataToHexString(advData), "D0000001C29D")
    }

    func testThatItSuccessfullyConvertEmptyAdvDataToNil() {
        let data: [CBUUID: Data?] = [CBUUID(string:"FE33") : nil, CBUUID(string:"FE65"): nil]
        let advData: [String: Any] = ["kCBAdvDataServiceData" : data]
        XCTAssertNil(utilities.byteDataToHexString(advData))
    }

    func testThatItSuccessfullyConvertsDataToBytes() {
        let data = Data(bytes: [0x01, 0x01, 0x01, 0x00, 0xd0, 0x00, 0x00, 0x01, 0xc2, 0x9d])
        let bytes = data.convertToBytes()
        XCTAssertFalse(bytes.isEmpty)
        XCTAssertEqual(bytes, [0x01, 0x01, 0x01, 0x00, 0xd0, 0x00, 0x00, 0x01, 0xc2, 0x9d])
    }
}
