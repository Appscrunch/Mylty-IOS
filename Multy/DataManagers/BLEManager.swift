//
//  BLEManager.swift
//  Multy
//
//  Created by Artyom Alekseev on 23.05.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import UIKit
import CoreBluetooth

typealias BLEManagerMapper = BLEManager

public let didDiscoverNewAdvertisementNotificationName = "didDiscoverNewAdvertisementNotificationName" // notification userInfo contains macID of new ad for "macID" key
public let bluetoothReachabilityChangedNotificationName = "bluetoothReachabilityChangedNotificationName"

enum BluetoothReachability {
    case unknown
    case notReachable
    case reachable
}

/*!
 *  @class Advertisement
 *
 *  @discussion Object received during the scanning.
 *
 */
class Advertisement: NSObject {
    
    let originID : UUID // ID of advertising device
    var userCode : String
    
    init(originID: UUID, userCode: String) {
        self.originID = originID
        self.userCode = userCode
        
        super.init()
    }
}

/*!
 *  @class BluetoothManager
 *
 *  @discussion Responded for the manipulation with CoreBluetooth entities.
 *
 */
class BLEManager: NSObject, CBCentralManagerDelegate {
    static let shared = BLEManager()
    
    private var centralManager : CBCentralManager
    private var peripheralManager : CBPeripheralManager
    private let serviceUUIDString = "8c0d3334-7711-44e3-b5c4-28b2"
    
    var isScanning : Bool {
        get {
            return self.centralManager.isScanning
        }
    }
    
    var isAdvertising : Bool {
        get {
            return self.peripheralManager.isAdvertising
        }
    }
    
    var receivedAds : [Advertisement]?
    
    var reachability = BluetoothReachability.unknown {
        didSet {
            if reachability != oldValue {
                NotificationCenter.default.post(name: Notification.Name(bluetoothReachabilityChangedNotificationName), object: nil)
            }
        }
    }
    
    override init() {
        let centralQueue = DispatchQueue(label: "BMCentralManagerQueue")
        centralManager = CBCentralManager.init(delegate: nil, queue: centralQueue)
        let peripheralQueue = DispatchQueue(label: "BMPeripheralManagerQueue")
        peripheralManager = CBPeripheralManager.init(delegate: nil, queue: peripheralQueue)
        
        super.init()
        
        centralManager.delegate = self
    }
    
    func serviceUUIDWithId(userId : String) -> CBUUID {
        return CBUUID.init(string: (serviceUUIDString + userId/*BLEManager.fromIdToUserCode(identifier: userId)*/))
    }
    
    func userIdFromServiceUUID(UUID : CBUUID) -> String? {
        if self.isUUIDisServiceUUID(UUID: UUID) == true {
            let UUIDString = UUID.uuidString
            let userIdString = UUIDString[self.serviceUUIDString.index(self.serviceUUIDString.startIndex, offsetBy: self.serviceUUIDString.count)...]
            return String(userIdString).uppercased()/*UInt32(userIdString, radix: 16)*/
        }
        
        return nil
    }
    
    func isUUIDisServiceUUID(UUID : CBUUID) -> Bool {
        var result = false
        let UUIDString = UUID.uuidString
        
        if UUIDString.hasPrefix(serviceUUIDString.uppercased()) {
            result = true
        }
        
        return result
    }
    
    static func fromIdToUserCode(identifier : UInt32) -> String {
        var mutId = identifier
        let idData = NSData(bytes: &mutId, length: MemoryLayout<UInt32>.size) as Data
        let bytesArray = [UInt8](idData).reversed() as [UInt8]
        var userCode = ""
        for index in 0..<bytesArray.count {
            userCode = userCode + String(format:"%02x", bytesArray[index])
        }
        
        return userCode
    }
    
    // MARK: Scanner
    func startScan() {
        if centralManager.state == .poweredOn {
            receivedAds = []
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("scan started")
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
        receivedAds = nil
        print("scan stopped")
    }
    
    func resetReceivedAds() {
        if self.isScanning == true {
            self.stopScan()
            self.startScan()
        }
    }
    
    // MARK: Broadcaster
    func advertise(userId: String) {
        let adData = [CBAdvertisementDataServiceUUIDsKey : [self.serviceUUIDWithId(userId: userId.uppercased()/*userId.uint32Value*/)]] as [String : Any]
        peripheralManager.startAdvertising(adData)
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    
    // MARK: Central manager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            reachability = BluetoothReachability.reachable
        } else if central.state != .unknown {
            reachability = BluetoothReachability.notReachable
        } else {
            reachability = .unknown
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Extract service UUID from received data
        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? NSArray {
            let originID = peripheral.identifier
            var userID : String?
            
            if let UUID = serviceUUIDs.firstObject as? CBUUID {
                // Define userID from extracted service UUID
                userID = self.userIdFromServiceUUID(UUID: UUID)
            }
            
            if userID != nil {
                // Create and add advertisement in list
                let ad = Advertisement.init(originID: originID, userCode : userID!)
                
                if receivedAds != nil {
                    var currentObjectIndexInList : Int?
                    for object in receivedAds! {
                        if object.originID == ad.originID {
                            currentObjectIndexInList = receivedAds!.index(of: object)
                            break
                        }
                    }
                    
                    if currentObjectIndexInList == nil {
                        receivedAds!.append(ad)
                    }
                    print("New ad")
                    NotificationCenter.default.post(name: Notification.Name(didDiscoverNewAdvertisementNotificationName), object: nil, userInfo: ["originID" : ad.originID])
                }
            }
        }
    }
}
