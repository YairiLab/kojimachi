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
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        delegate.log("\(central.state)")
    }
    
    func scan() {
        central.scanForPeripheralsWithServices(
            [MSCentralManager.servUuid],
            options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        delegate.log("peripheral found: \(peripheral). advertisementData:\(advertisementData)")
        
        central.connectPeripheral(peripheral, options: nil)
        delegate.log("peripheral \(peripheral.name ?? "no name") is connected")
        peripheral.delegate = self
        peripherals[peripheral] = []
        
    }
    
    func stopScan() {
        central.stopScan()
    }
    
    func sensorStart() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "start".dataUsingEncoding(NSUTF8StringEncoding)
                p.writeValue(data!, forCharacteristic: c, type: .WithResponse)
            }
        }
    }
    
    
    func sensorStop() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "stop".dataUsingEncoding(NSUTF8StringEncoding)
                p.writeValue(data!, forCharacteristic: c, type: .WithResponse)
            }
        }
    }
    
    func textWrite() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "write:Hello!".dataUsingEncoding(NSUTF8StringEncoding)
                p.writeValue(data!, forCharacteristic: c, type: .WithResponse)
            }
        }
    }

    func introduce() {
        for (p, chars) in peripherals {
            for c in chars {
                let data = "introduce".dataUsingEncoding(NSUTF8StringEncoding)
                p.writeValue(data!, forCharacteristic: c, type: .WithResponse)
            }
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        delegate.log("peripheral \(peripheral.name ?? "no name") is connected")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        delegate.log("ERROR: \(error)")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for s in peripheral.services! {
            delegate.log("service found: \(s), \(s.UUID.UUIDString)")
            if s.UUID.isEqual(MSCentralManager.servUuid) {
                peripheral.discoverCharacteristics(nil, forService: s)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        peripherals[peripheral] = service.characteristics!
        for char in service.characteristics! {
            delegate.log("charecteristic found: \(char.UUID) at \(peripheral.name!)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
            if let e = error {
                delegate.log("ERROR: \(e)")
            } else {
                let s = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
                delegate.log("\(characteristic.UUID) returned \(s)")
            }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
            if let e = error {
                delegate.log("ERROR: \(e)")
            } else {
                //let s = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
                delegate.log("\(characteristic.UUID) succeeded")
            }
    }
}
