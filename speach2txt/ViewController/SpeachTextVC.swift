//
//  ViewController.swift
//  speach2txt
//
//  Created by Xin Zou on 10/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var isRecording = false
    
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
    
    
}
