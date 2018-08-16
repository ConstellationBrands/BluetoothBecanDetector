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
    
    override init() {
        super.init()
        
        self.dataManager = JSONService()
        self.userLocationService = UserLocationService()
        userLocationService?.startTracking()
        userLocationService?.getUserCurrentLocation { (location) in
            self.currLocation = location
        }

        self.centralManager = CBCentralManager(delegate: self, queue: nil, options:
            [ CBCentralManagerOptionRestoreIdentifierKey : [kBGRestoreId], CBCentralManagerScanOptionAllowDuplicatesKey : false, CBCentralManagerScanOptionSolicitedServiceUUIDsKey : [bgServiceID] ])
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(kTimerFrequency), target: self, selector: #selector(monitorBeacons), userInfo: nil, repeats: true)
    }
    
    //MARK: Actions
    public func startScan() {
        self.centralManager.scanForPeripherals(withServices: [bgServiceID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true, CBCentralManagerScanOptionSolicitedServiceUUIDsKey : [bgServiceID]])
    }
    
    public func stopScan() {
        self.centralManager.stopScan()
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
    
    //MARK: Scanning
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //  If our mirrors array contains a mirror representing that peripheral
        if let existingBeacon = Beacon.getBeacon(beacons: beacons, peripheral: peripheral) {
            existingBeacon.lastSeen = Date()
        } else { // Otherwise, create a new PhysicalMirror out of the discovered peripheral
            let beacon = Beacon(advData: advertisementData, periph: peripheral, RSSI: RSSI)
            beacons.append(beacon)
            self.foundBeacon?(beacon)
            let params: [String: Any] = ["device_id":  UIDevice.current.identifierForVendor!.uuidString, "beacon_id":  Utilities.sharedInstance.byteDataToHexString(advertisementData) ?? "NIL", "latitude": currLocation?.coordinate.latitude ?? NSNull(), "longitude": currLocation?.coordinate.longitude ?? NSNull(), "altitude": currLocation?.altitude ?? NSNull(), "floor": currLocation?.floor?.level ?? NSNull(), "horizontal_accuracy": currLocation?.horizontalAccuracy ?? NSNull(), "vertical_accuracy": currLocation?.verticalAccuracy ?? NSNull(), "RSSI": beacon.RSSString ?? NSNull(), "tx_power": beacon.txPowerLevel ?? NSNull(), "date_time": NSDate().description]
            dataManager.sendData(url: serviceURL, withData: params) { _ in }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let beacon = Beacon.getBeacon(beacons: beacons, peripheral: peripheral) {
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

    //Restore
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        let _ = Bluetooth.sharedInstance
        Bluetooth.sharedInstance.startScan()
    }
}