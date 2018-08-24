//
//  JsonServiceTests.swift
//  BluetoothBeaconDetectorTests
//
//  Created by Vishal Bharam on 8/22/18.
//  Copyright © 2018 Vishal Bharam. All rights reserved.
//

import XCTest
import Foundation
@testable import BluetoothBeaconDetector

class JsonServiceTests: XCTestCase {

    var jsonService: JSONService!

    class TestJsonService: JSONService {
        override func sendData(url: String, withData params: [String : Any], completionHandler: @escaping (([String : Any]?) -> Void)) {
            completionHandler(nil)
        }

        override func getData(url: String, completionHandler: @escaping (([String : Any]?) -> Void)) {
            completionHandler(nil)
        }
    }
    
    override func setUp() {
        super.setUp()
        jsonService = TestJsonService()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatItSendsDataSuccessfully() {
        let params: [String: Any] =  ["device_id":  "1234-5679", "beacon_id":  "UA1234", "latitude": 37.412, "longitude": -122.546, "altitude": 10.0, "floor": NSNull(), "horizontal_accuracy": 65, "vertical_accuracy": 10, "RSSI": "-73", "tx_power": NSNull(), "date_time": "2018-08-22 19:46:52 +0000"]
        jsonService.sendData(url: "", withData: params) { (response) in
            XCTAssertNil(response)
        }
    }

    func testThatItGetsDataSuccessfully() {
        jsonService.getData(url: "") { (response) in
            XCTAssertNil(response)
        }
    }
    
}
