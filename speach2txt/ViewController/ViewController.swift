//
//  ViewController.swift
//  speach2txt
//
//  Created by Xin Zou on 10/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    let placeHolder = "Say something😆, I am listening!"
    lazy var textView : UITextView = {
        let t = UITextView()
        t.font = UIFont.systemFont(ofSize: 26)
        //t.delegate = self
        t.layer.borderColor = UIColor.lightGray.cgColor
        t.layer.borderWidth = 1
        return t
    }()

    lazy var micphoneButton : UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(micphonButtonTapped), for: .touchUpInside)
        b.setImage(#imageLiteral(resourceName: "micphone"), for: .normal)
        b.contentMode = .scaleAspectFill
        b.layer.cornerRadius = 40
        b.layer.masksToBounds = true
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupTextView()
        setupMicphoneButton()
     
        setupSpeech()
    }
    
    private func setupTextView(){
        textView.text = placeHolder
        view.addSubview(textView)
        textView.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 30, topConstent: 40, rightConstent: 30, bottomConstent: 60, width: 0, height: 0)
    }
    private func setupMicphoneButton(){
        view.addSubview(micphoneButton)
        micphoneButton.addConstraints(left: nil, top: nil, right: nil, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 20, width: 80, height: 80)
        micphoneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupSpeech(){
        micphoneButton.isEnabled = false  //2
        speechRecognizer?.delegate = self  //3
        
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
                self.micphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("get error: didReceiveMemoryWarning()...")
    }


}


extension ViewController {
    
    @objc func micphonButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            micphoneButton.isEnabled = false
            micphoneButton.setImage(#imageLiteral(resourceName: "micphone"), for: .normal)
        } else {
            startRecording()
            micphoneButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode as AVAudioInputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            print("recognitionRequest isFinal = \(isFinal)") // TODO: rmeove this!!!
            if result != nil {  // MARK: -  get current result and put into textView
                let getTxt = result?.bestTranscription.formattedString ?? ""
                print("get text = \(getTxt)")
                self.textView.text = getTxt
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.micphoneButton.isEnabled = true
            }
        }) 
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let err {
            print("audioEngine couldn't start because of an error: \(err)")
        }
        textView.text = placeHolder
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        micphoneButton.isEnabled = available
    }
    
    
}
