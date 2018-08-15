//
//  Bluetooth.swift
//  Beejee
//
//  Created by Vik Denic on 3/16/17.
//  Copyright © 2017 Vik Denic. All rights reserved.
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
    var simblees = [Simblee]()
    var bgServiceID: CBUUID = CBUUID(string: kBGCustomUUID)
    
    var foundSimblee : ((_ simblee: Simblee?) -> ())? = nil
    var lostSimblee : ((_ mirror: Simblee?) -> ())? = nil
    var scanStateChanged : ((_ state: CBManagerState) -> ())? = nil
    var timer = Timer()
    
    override init() {
        super.init()
        
        // Diagnostics.writeToPlist("Bluetooth class init")
        self.dataManager = JSONService()
        self.userLocationService = UserLocationService()
        userLocationService?.startTracking()
        userLocationService?.getUserCurrentLocation { (location) in
            self.currLocation = location
        }

        self.centralManager = CBCentralManager(delegate: self, queue: nil, options:
            [ CBCentralManagerOptionRestoreIdentifierKey : [kBGRestoreId], CBCentralManagerScanOptionAllowDuplicatesKey : false, CBCentralManagerScanOptionSolicitedServiceUUIDsKey : [bgServiceID] ])
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(kTimerFrequency), target: self, selector: #selector(monitorSimblees), userInfo: nil, repeats: true)
    }
    
    //MARK: Actions
    public func startScan() {
        // Diagnostics.writeToPlist("startScan for peripherals with UUID : \(bgServiceID)")
        
        self.centralManager.scanForPeripherals(withServices: [bgServiceID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true, CBCentralManagerScanOptionSolicitedServiceUUIDsKey : [bgServiceID]])
    }
    
    public func stopScan() {
        // Diagnostics.writeToPlist("Stopping scan")
        self.centralManager.stopScan()
    }
    
    @objc func monitorSimblees() {
        var theLostSimblee: Simblee?
        for simblee in simblees {
            if (simblee.lastSeen?.timeIntervalSinceNow)! < kMinCutoffTime {
                theLostSimblee = simblee
            }
        }
        
        simblees = simblees.filter() {($0.lastSeen?.timeIntervalSinceNow)! > kMinCutoffTime} //updates array
        
        if let theLostSimblee = theLostSimblee {
            lostSimblee?(theLostSimblee)
        }
    }
    
}

extension Bluetooth: CBCentralManagerDelegate {
    
    //MARK: Scanning
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Diagnostics.writeToPlist("didDiscover peripheral")
        
        //  If our mirrors array contains a mirror representing that peripheral
        if let existingSimblee = Simblee.getSimblee(simblees: simblees, peripheral: peripheral) {
            existingSimblee.lastSeen = Date()
            print("Simblee already detected")
        } else { // Otherwise, create a new PhysicalMirror out of the discovered peripheral
            let simblee = Simblee(advData: advertisementData, periph: peripheral, RSSI: RSSI)
            simblees.append(simblee)
            self.foundSimblee?(simblee)
            print("New Simblee detected")
            // UNNotification.scheduleNotif(title: "Found new Simblee", body: (simblee.peripheral?.identifier.uuidString)!)
            // Diagnostics.writeToPlist("Found new peripheral : \((simblee.peripheral?.identifier.uuidString)!)")

            // Send data:
            let params: [String: Any] = ["device_id":  UIDevice.current.identifierForVendor!.uuidString, "beacon_id":  Utilities.sharedInstance.byteDataToHexString(advertisementData) ?? "NIL", "latitude": currLocation?.coordinate.latitude ?? NSNull(), "longitude": currLocation?.coordinate.longitude ?? NSNull(), "altitude": currLocation?.altitude ?? NSNull(), "floor": currLocation?.floor?.level ?? NSNull(), "horizontal_accuracy": currLocation?.horizontalAccuracy ?? NSNull(), "vertical_accuracy": currLocation?.verticalAccuracy ?? NSNull(), "RSSI": simblee.RSSString ?? NSNull(), "tx_power": simblee.txPowerLevel ?? NSNull(), "date_time": NSDate().description]

            dataManager.sendData(url: apiEndPoint, withData: params) { (data) in

            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let simblee = Simblee.getSimblee(simblees: simblees, peripheral: peripheral) {
            lostSimblee?(simblee)
        }
    }


    @available(iOS 5.0, *)
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Diagnostics.writeToPlist("centralManagerDidUpdateState: \(central.state)")
        switch central.state {
        case .poweredOn:
            startScan()
        default :
            simblees.removeAll()
        }
        scanStateChanged?(central.state)
    }

    //Restore
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        Diagnostics.writeToPlist("willRestoreState")
        let _ = Bluetooth.sharedInstance
        Bluetooth.sharedInstance.startScan()
    }
}
