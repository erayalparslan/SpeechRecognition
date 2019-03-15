//
//  SpeechRecognitionWithSwift.swift
//  ObjectiveSpeechExample
//
//  Created by ruroot on 11/25/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import Foundation
import Speech

@objc protocol SpeechRecognitionWithSwiftDelegate {
    func didPrepareSpeech(_ controller: SpeechRecognitionWithSwift, finalString: String, isMicButtonEnabled: Bool, labelString: String)
}

@objc class SpeechRecognitionWithSwift: NSObject {
    var finalString = ""
    var isMicButtonEnabled = true
    var labelString = ""
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    var timer: Timer?
    @objc var delegate: SpeechRecognitionWithSwiftDelegate?
    
    @objc func customInit() {
        isMicButtonEnabled = false
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.isMicButtonEnabled = isButtonEnabled
            }
        }
        self.delegate?.didPrepareSpeech(self, finalString: self.finalString, isMicButtonEnabled: self.isMicButtonEnabled, labelString: self.labelString)
    }
    
    
    @objc func micButtonPressedFunc() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isMicButtonEnabled = false
            labelString = "Start Recording";
        } else {
            startRecording()
            labelString = "Stop Recording";
        }
        self.delegate?.didPrepareSpeech(self, finalString: self.finalString, isMicButtonEnabled: self.isMicButtonEnabled, labelString: self.labelString)
    }
    
    
    @objc func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.finalString = result?.bestTranscription.formattedString ?? ""
                self.delegate?.didPrepareSpeech(self, finalString: self.finalString, isMicButtonEnabled: self.isMicButtonEnabled, labelString: self.labelString)
                //print(self.finalString)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isMicButtonEnabled = true
            }
            else if error == nil {
                self.restartSpeechTimer(inputNode: inputNode)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
    
        do {
            try audioEngine.start()
            self.isMicButtonEnabled = false
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.finalString = "Bişey gonuş gardaş dinliyom ben"
        
    }
    
    func restartSpeechTimer(inputNode node: AVAudioInputNode) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
            // Do whatever needs to be done when the timer expires
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: self.lang))
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.isMicButtonEnabled = true
            self.labelString = "press again to talk"
            self.delegate?.didPrepareSpeech(self, finalString: self.finalString, isMicButtonEnabled: self.isMicButtonEnabled, labelString: self.labelString)
        })
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.isMicButtonEnabled = true
        } else {
            self.isMicButtonEnabled = false
        }
    }
    
    
    

}
