//
//  ViewController.swift
//  speach2txt
//
//  Created by Xin Zou on 10/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class SpeachTextVC: UIViewController {
    
    let placeHolder = "tap button and say hello 😆"
    
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
    
    var pulsatingLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupTextView()
        setupButtonPulsLayer()
        setupMicphoneButton()

        AudioServer.share.setupSpeech { (success) in
            //
        }
    }
    
    private func setupTextView(){
        textView.text = placeHolder
        textView.allowsEditingTextAttributes = false
        textView.isUserInteractionEnabled = false
        view.addSubview(textView)
        textView.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 30, topConstent: 40, rightConstent: 30, bottomConstent: 60, width: 0, height: 0)
    }
    private func setupMicphoneButton(){
        view.addSubview(micphoneButton)
        micphoneButton.addConstraints(left: nil, top: nil, right: nil, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 20, width: 80, height: 80)
        micphoneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupButtonPulsLayer() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 43, startAngle: -CGFloat.pi / 2.0, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        // startAngle: [ -pi/2: 0'oclock, 0: 3'oclock, pi/2 = 6'oclock]
        
        // add pulsatingLayer:
        pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circularPath.cgPath
        pulsatingLayer.strokeColor = UIColor.clear.cgColor // line color
        pulsatingLayer.fillColor = UIColor.orange.cgColor // in circle color
        view.layer.addSublayer(pulsatingLayer)
        pulsatingLayer.position = CGPoint(x: view.center.x, y: view.bounds.height - 60)
        animatePulsatingLayer()
    }
    
    private func animatePulsatingLayer() {
        let animate = CABasicAnimation(keyPath: "transform.scale")
        animate.toValue = 1.2
        animate.duration = 2.0
        animate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animate.repeatCount = 1000
        animate.autoreverses = true
        pulsatingLayer.add(animate, forKey: "pulsing")
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("get error: didReceiveMemoryWarning()...")
    }
}


extension SpeachTextVC {
    
    @objc func micphonButtonTapped() {
        if AudioServer.share.audioEngine.isRunning {
            AudioServer.share.stopRecording()
            micphoneButton.setImage(#imageLiteral(resourceName: "micphone"), for: .normal)
            pulsatingLayer.fillColor = UIColor.orange.cgColor
        } else {
            AudioServer.share.startRecording(completion: { (isFinal, getText) in
                self.textView.text = getText
            })
            micphoneButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            pulsatingLayer.fillColor = UIColor.yellow.cgColor
        }
    }
    
    
}
