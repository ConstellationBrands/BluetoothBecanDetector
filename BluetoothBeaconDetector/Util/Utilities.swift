//
//  Utilities.swift
//  CBI Radar
//
//  Created by Vishal Bharam on 7/9/18.
//  Copyright © 2018 Vik Denic. All rights reserved.
//

import Foundation
import CoreBluetooth

class Utilities {

    static let sharedInstance = Utilities()

    // Method to convert a byte array into a string containing hex characters, without any
    /// additional formatting.
    func byteDataToHexString(_ advertisingData : [String : Any]?) -> String? {

        let serviceData = advertisingData?[CBAdvertisementDataServiceDataKey] as? [NSObject : AnyObject]
        let beaconServiceData = serviceData?[CBUUID(string: kBGCustomUUID)] as? NSData
        if let count = beaconServiceData?.length {
            var frameBytes = [UInt8](repeating: 0, count: count)
            beaconServiceData?.getBytes(&frameBytes, length: count)
            let byteArray: [UInt8] = Array(frameBytes[4..<10])

            var stringToReturn = ""
            let CHexLookup : [Character] =
                [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]

            for oneByte in byteArray {
                let asInt = Int(oneByte)
                stringToReturn.append(CHexLookup[asInt >> 4])
                stringToReturn.append(CHexLookup[asInt & 0x0f])
            }
            return stringToReturn
        }
        return nil
    }
}
