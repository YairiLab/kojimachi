//
//  YLSpeechSynthesizer.swift
//  Textbook
//
//  Created by Hiloki OE on 9/24/14.
//  Copyright (c) 2014 sophia univ. All rights reserved.
//

import AVFoundation

public class MSSpeechSynthesizer: NSObject {
    let speaker: AVSpeechSynthesizer
    
    public override init() {
        speaker = AVSpeechSynthesizer()
    }
    
    public func speak(s: String) {
        if speaker.speaking {
            speaker.stopSpeakingAtBoundary(.Immediate)
        }
        let ut = AVSpeechUtterance(string: s)
        ut.voice = AVSpeechSynthesisVoice(language: "en-us")
        ut.rate = 0.5
        speaker.speakUtterance(ut)
    }
}