//
//  Simblee.swift
//  Beejee
//
//  Created by Vik Denic on 3/16/17.
//  Copyright © 2017 Vik Denic. All rights reserved.
//

import Foundation
import CoreBluetooth

//MARK: Bluetooth
typealias Byte = UInt8
//typealias BLEPacket = [Byte]
//typealias BLEMessage = [BLEPacket]

class Simblee {
    
    var serialNumber: String?
    var version: String?
    var peripheral: CBPeripheral?
    var lastSeen: Date?
    private let RSSI: NSNumber?
    private let nilString = "nil"

    var advertisingData : [String : Any]? = nil {
        didSet {
            if let data = advertisingData?["kCBAdvDataManufacturerData"] as? Data {
                serialNumber = Simblee.extractSerialNumber(advertisementData: advertisingData! as [String : Any])
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


    /*

    var connectableBool:Bool {
        let num = advertisingData[CBAdvertisementDataIsConnectable] as? NSNumber
        if num != nil {
            return num!.boolValue
        }
        else {
            return false
        }
    }

    var localName:String {
        var nameString = advertisingData[CBAdvertisementDataLocalNameKey] as? NSString
        if nameString == nil {
            nameString = nilString
        }
        return nameString! as String
    }

    var manufacturerData:String {
        let newData = advertisingData[CBadvertisingDataManufacturerDataKey] as? NSData
        if newData == nil {
            return nilString
        }
        let dataString = newData?.hexRepresentation()

        return dataString!
    }

    var serviceData:String {
        let dict = advertisingData[CBadvertisingDataServiceDataKey] as? NSDictionary
        if dict == nil {
            return nilString
        }
        else {
            return dict!.description
        }
    }

    var serviceUUIDs:[String] {
        let svcIDs = advertisingData[CBadvertisingDataServiceUUIDsKey] as? NSArray
        if svcIDs == nil {
            return [nilString]
        }
        return self.stringsFromUUIDs(svcIDs!)
    }

    var overflowServiceUUIDs:[String] {
        let ovfIDs = advertisingData[CBadvertisingDataOverflowServiceUUIDsKey] as? NSArray

        if ovfIDs == nil {
            return [nilString]
        }
        return self.stringsFromUUIDs(ovfIDs!)
    }
 */


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
    
    class func getSimblee(simblees : [Simblee], peripheral : CBPeripheral) -> Simblee? {
        let result = simblees.filter{$0.peripheral?.identifier.uuidString == peripheral.identifier.uuidString}
        return result.first
    }
}
