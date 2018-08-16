//
//  Beacon.swift
//  Beejee
//
//  Created by Vishal Bharam on 7/5/18.
//  Copyright © 2018 Vishal Bharam. All rights reserved.
//

import Foundation
import CoreBluetooth

class Beacon {
    
    var serialNumber: String?
    var version: String?
    var peripheral: CBPeripheral?
    var lastSeen: Date?
    private let RSSI: NSNumber?
    private let nilString = "nil"
    
    var advertisingData : [String : Any]? = nil {
        didSet {
            if let data = advertisingData?["kCBAdvDataManufacturerData"] as? Data {
                serialNumber = Beacon.extractSerialNumber(advertisementData: advertisingData! as [String : Any])
                let bytes = data.convertToBytes()
                if bytes.count > 8 {
                    version = String(bytes[6]) + "." + String(bytes[7]) + "." + String(bytes[8])
                }
            }
        }
    }
    
    init(advData: [String : Any], periph: CBPeripheral, RSSI: NSNumber) {
        self.advertisingData = advData
        self.peripheral = periph
        self.RSSI = RSSI
        self.lastSeen = Date()
    }
    
    var RSSString: String? {
        return RSSI?.description
    }
    
    var txPowerLevel: String? {
        let txNum = advertisingData?[CBAdvertisementDataTxPowerLevelKey] as? NSNumber
        return txNum?.description
    }
    
    class func extractSerialNumber(advertisementData: [String : Any]) -> String {
        if let data = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            let value = data[2...5]
            var stringValue = ""
            for byte in value {
                stringValue = stringValue + String(byte, radix: 16)
            }
            return stringValue
        }
        return ""
    }
    
    class func getBeacon(beacons : [Beacon], peripheral : CBPeripheral) -> Beacon? {
        let result = beacons.filter{$0.peripheral?.identifier.uuidString == peripheral.identifier.uuidString}
        return result.first
    }
}