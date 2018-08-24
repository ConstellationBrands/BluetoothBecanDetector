//
//  Bluetooth.swift
//  Beejee
//
//  Created by Vishal Bharam on 7/5/18.
//  Copyright © 2018 Vishal Bharam. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation
import UserNotifications

public class Bluetooth: NSObject {
    public static let sharedInstance = Bluetooth()
    public let logger = Logger()
    var dataManager: JSONService!
    var userLocationService: UserLocationService?
    var currLocation: CLLocation?
    var centralManager: CBCentralManager!
    
    var beacons = [Beacon]()
    var bgServiceID: CBUUID = CBUUID(string: kBGCustomUUID)
    
    var foundBeacon : ((_ beacon: Beacon?) -> ())? = nil
    var lostBeacon : ((_ mirror: Beacon?) -> ())? = nil
    var scanStateChanged : ((_ state: CBManagerState) -> ())? = nil
    var timer = Timer()
    
    public init(jsonService: JSONService = JSONService(), userLocationService: UserLocationService = UserLocationService()) {
        super.init()
        self.dataManager = jsonService
        self.userLocationService = userLocationService
        startLocationService()
        startCentralMangerAndTimer()
    }
    
    public func startScan() {
        self.centralManager.scanForPeripherals(withServices: [bgServiceID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true, CBCentralManagerScanOptionSolicitedServiceUUIDsKey : [bgServiceID]])
        if logger.isDebugModeOn {
            print("scan started for \(bgServiceID)")
        }
    }
    
    public func stopScan() {
        self.centralManager.stopScan()
        if logger.isDebugModeOn {
            print("scan stopped")
        }
    }
}

// MARK: - Private fuctions
extension Bluetooth {
    private func startLocationService() {
        userLocationService?.startTracking()
        userLocationService?.getUserCurrentLocation { (location) in
            self.currLocation = location
        }
    }
    
    private func startCentralMangerAndTimer() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options:
            [ CBCentralManagerOptionRestoreIdentifierKey : [kBGRestoreId], CBCentralManagerScanOptionAllowDuplicatesKey : false, CBCentralManagerScanOptionSolicitedServiceUUIDsKey : [bgServiceID] ])
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(kTimerFrequency), target: self, selector: #selector(monitorBeacons), userInfo: nil, repeats: true)
    }
    
    private func createParameter(forBeacon beacon: Beacon, forDiscover peripheral: CBPeripheral, forAdvertisementData advertisementData: [String : Any]) -> [String: Any] {
        let params: [String: Any] =  ["device_id":  UIDevice.current.identifierForVendor!.uuidString, "beacon_id":  Utilities.sharedInstance.byteDataToHexString(advertisementData) ?? "NIL", "latitude": currLocation?.coordinate.latitude ?? NSNull(), "longitude": currLocation?.coordinate.longitude ?? NSNull(), "altitude": currLocation?.altitude ?? NSNull(), "floor": currLocation?.floor?.level ?? NSNull(), "horizontal_accuracy": currLocation?.horizontalAccuracy ?? NSNull(), "vertical_accuracy": currLocation?.verticalAccuracy ?? NSNull(), "RSSI": beacon.RSSString ?? NSNull(), "tx_power": beacon.txPowerLevel ?? NSNull(), "date_time": NSDate().description]
        return params
    }
    
    @objc func monitorBeacons() {
        var theLostBeacon: Beacon?
        for beacon in beacons {
            if (beacon.lastSeen?.timeIntervalSinceNow)! < kMinCutoffTime {
                theLostBeacon = beacon
            }
        }
        beacons = beacons.filter() {($0.lastSeen?.timeIntervalSinceNow)! > kMinCutoffTime} //updates array
        if let theLostBeacon = theLostBeacon {
            lostBeacon?(theLostBeacon)
        }
    }
}

extension Bluetooth: CBCentralManagerDelegate {
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let existingBeacon = Beacon.getBeacon(forBeacons: beacons, forPeripheral: peripheral) {
            existingBeacon.lastSeen = Date()
        } else {
            let beacon = Beacon(advData: advertisementData, periph: peripheral, RSSI: RSSI)
            beacons.append(beacon)
            self.foundBeacon?(beacon)
            let params = self.createParameter(forBeacon: beacon, forDiscover: peripheral, forAdvertisementData: advertisementData)
            dataManager.sendData(url: serviceURL, withData: params) { _ in
                if self.logger.isDebugModeOn {
                    print("Data Mananger send the becaon data \(beacon)")
                }
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let beacon = Beacon.getBeacon(forBeacons: beacons, forPeripheral: peripheral) {
            lostBeacon?(beacon)
        }
    }

    @available(iOS 5.0, *)
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startScan()
        default :
            beacons.removeAll()
        }
        scanStateChanged?(central.state)
    }

    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        Bluetooth.sharedInstance.startScan()
    }
}
