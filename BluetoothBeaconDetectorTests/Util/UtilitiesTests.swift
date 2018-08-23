//
//  UtilitiesTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Saranya Jayaseelan. All rights reserved.
//

import Foundation
import XCTest
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
//        let data = [FE33: <01010100 d0000001 c29d>, FE65: <01>]
//        let advData: [String: Any] = ["kCBAdvDataServiceData" : data]
//        XCTAssertEqual(utilities.byteDataToHexString(advData), "D0000001C29D")
    }
}
