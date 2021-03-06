//
//  ViewController.swift
//  WheelChairSensorController
//
//  Created by Phil Owen on 11/23/15.
//  Copyright © 2015 Phil Owen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MSCentralManagerDelegate {
    let speaker = MSSpeechSynthesizer()
    var central: MSCentralManager!
    
    @IBOutlet weak var label: UILabel!
    @IBAction func scan(_ sender: UIButton) {
        beep()
        central.scan()
    }
    
    @IBAction func stopScan(_ sender: UIButton) {
        beep()
        speak(s: "\(central.peripherals.count) peripherals found")
        central.stopScan()
    }
    
    @IBAction func comTest(_ sender: UIButton) {
        beep()
        central.textWrite()
    }
    
    @IBAction func comTest2(_ sender: UIButton) {
        beep()
        central.introduce()
    }
    
    @IBAction func sensorStart(_ sender: UIButton) {
        beep()
        central.sensorStart()
    }
    
    @IBAction func sensorStop(_ sender: UIButton) {
        beep()
        central.sensorStop()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        central = MSCentralManager(delegate: self)
    }
    
    func log(s: String) {
        label.text = s
        print(s)
    }
    
    func beep() {
        speaker.speak(s: "peep")
    }
    
    func speak(s: String) {
        speaker.speak(s: s)
    }
}

