//
//  Beacon.swift
//  Beejee
//
//  Created by Vishal Bharam on 7/5/18.
//  Copyright © 2018 Vishal Bharam. All rights reserved.
//

import Foundation
import CoreBluetooth

public class Beacon {
    var serialNumber: String?
    var version: String?
    var peripheral: CBPeripheral?
    var lastSeen: Date?
    let RSSI: NSNumber?
    var advertisingData : [String : Any]? = nil {
        didSet {
            if let data = advertisingData?[kCBAdvertisementManufacturerDataKey] as? Data {
                serialNumber = Beacon.getSerialNumber(foradvertisementData: advertisingData! as [String : Any])
                let bytes = data.convertToBytes()
                if bytes.count > 8 {
                    version = String(bytes[6]) + "." + String(bytes[7]) + "." + String(bytes[8])
                }
            }
        }
    }
    var RSSString: String? {
        return RSSI?.description
    }
    var txPowerLevel: String? {
        let txNum = advertisingData?[CBAdvertisementDataTxPowerLevelKey] as? NSNumber
        return txNum?.description
    }
    
    init(advData: [String : Any], periph: CBPeripheral, RSSI: NSNumber) {
        self.advertisingData = advData
        self.peripheral = periph
        self.RSSI = RSSI
        self.lastSeen = Date()
    }
}

extension Beacon {
    class func getSerialNumber(foradvertisementData advertisementData : [String : Any]) -> String? {
        if let data = advertisementData[kCBAdvertisementManufacturerDataKey] as? Data {
            let value = data[2...5]
            var stringValue = ""
            for byte in value { stringValue = stringValue + String(byte, radix: 16) }
            return stringValue
        }
        return nil
    }
    
    class func getBeacon(forBeacons  beacons: [Beacon], forPeripheral peripheral : CBPeripheral) -> Beacon? {
        return beacons.filter{$0.peripheral?.identifier.uuidString == peripheral.identifier.uuidString}.first
    }
}
