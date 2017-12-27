//
//  YLCentralManager.swift
//  WheelChairSensorController
//
//  Created by Phil Owen on 11/23/15.
//  Copyright © 2015 Phil Owen. All rights reserved.
//

import UIKit
import CoreBluetooth
import MapKit

protocol MSCentralManagerDelegate {
    func log(s: String)
    func beep()
}

class MSCentralManager: NSObject,
    CBCentralManagerDelegate, CBPeripheralDelegate {
    let delegate: MSCentralManagerDelegate
    var central: CBCentralManager!
    var peripherals = [CBPeripheral: [CBCharacteristic]]()
    static let charUuid = CBUUID(string: "EA644349-F3DC-48C9-BD8C-4394434A21C0")
    static let servUuid = CBUUID(string: "47603621-4AE3-4E44-92D9-64688AD8D6FB")

    init(delegate: MSCentralManagerDelegate) {
        self.delegate = delegate
        central = nil
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate.log(s: "\(central.state)")
    }
    
    func scan() {
        central.scanForPeripherals(
            withServices: [MSCentralManager.servUuid],
            options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        delegate.log(s: "peripheral found: \(peripheral). advertisementData:\(advertisementData)")
        
        central.connect(peripheral, options: nil)
        delegate.log(s: "peripheral \(peripheral.name ?? "no name") is connected")
        peripheral.delegate = self
        peripherals[peripheral] = []
        
    }
    
    func stopScan() {
        central.stopScan()
    }
    
    func sensorStart() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "start".data(using: String.Encoding.utf8)
                p.writeValue(data!, for: c, type: .withResponse)
            }
        }
    }
    
    
    func sensorStop() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "stop".data(using: String.Encoding.utf8)
                p.writeValue(data!, for: c, type: .withResponse)
            }
        }
    }
    
    func textWrite() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "write:Hello!".data(using: String.Encoding.utf8)
                p.writeValue(data!, for: c, type: .withResponse)
            }
        }
    }

    func introduce() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "introduce".data(using: String.Encoding.utf8)
                p.writeValue(data!, for: c, type: .withResponse)
            }
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        delegate.log(s: "peripheral \(peripheral.name ?? "no name") is connected")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate.log(s: "ERROR: \(String(describing: error))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s in peripheral.services! {
            delegate.log(s: "service found: \(s), \(s.uuid.uuidString)")
            if s.uuid.isEqual(MSCentralManager.servUuid) {
                peripheral.discoverCharacteristics(nil, for: s)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        peripherals[peripheral] = service.characteristics!
        for char in service.characteristics! {
            delegate.log(s: "charecteristic found: \(char.uuid) at \(peripheral.name!)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            if let e = error {
                delegate.log(s: "ERROR: \(e)")
            } else {
                let s = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
                delegate.log(s: "\(characteristic.uuid) returned \(String(describing: s))")
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            if let e = error {
                delegate.log(s: "ERROR: \(e)")
            } else {
                //let s = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
                delegate.log(s: "\(characteristic.uuid) succeeded")
            }
    }
}
