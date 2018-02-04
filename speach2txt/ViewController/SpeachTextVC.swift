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
        t.delegate = self
        t.font = UIFont.systemFont(ofSize: 26)
        t.layer.borderColor = UIColor.lightGray.cgColor
        t.layer.borderWidth = 1
        return t
    }()
    
    var timer: Timer!
    var lastText: String = ""
    var sentences: [Sentence] = []
    
    let tableView = UITableView()
    let cellId = "tableCellId"

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
        setupTableView()
        setupButtonPulsLayer()
        setupMicphoneButton()
        setupTimer()

        AudioServer.share.setupSpeech { (success) in
            //
        }
    }
    
    private func setupTextView(){
        textView.text = placeHolder
        textView.allowsEditingTextAttributes = false
        textView.isUserInteractionEnabled = true
        view.addSubview(textView)
        textView.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: view.rightAnchor, bottom: nil, leftConstent: 30, topConstent: 40, rightConstent: 30, bottomConstent: 0, width: 0, height: 100)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(SentenceTableCell.self, forCellReuseIdentifier: cellId)
        view.addSubview(tableView)
        tableView.addConstraints(left: view.leftAnchor, top: textView.bottomAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
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
        animate.repeatCount = Float(Int.max)
        animate.autoreverses = true
        pulsatingLayer.add(animate, forKey: "pulsing")
    }

    internal func setupTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkVoiceText), userInfo: nil, repeats: true)
    }
    
    @objc func checkVoiceText() {
        if AudioServer.share.audioEngine.isRunning {
            if let newText = self.textView.text, !newText.isEmpty, newText == self.lastText { // finished
                print("[TIMER] 1. timeup, textView.text = \(newText), lastText = \(self.lastText)")
                //self.micphonButtonTapped() // stop recording
                self.sentences.append(Sentence(string: newText))
                self.tableViewReloadData()
                self.textView.text = ""
                //self.micphonButtonTapped() // start recording again

            } else {
                self.lastText = self.textView.text
            }
        } else {
            //print("[TIMER] 0. AudioEngine is NOT running.")
        }
    }
    
    internal func tableViewReloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("get error: didReceiveMemoryWarning()...")
    }
}


extension SpeachTextVC {
    
    @objc func micphonButtonTapped() {
        if AudioServer.share.audioEngine.isRunning {
            print("[AUDIO] ------ stop ------")
            AudioServer.share.stopRecording()
            micphoneButton.setImage(#imageLiteral(resourceName: "micphone"), for: .normal)
            pulsatingLayer.fillColor = UIColor.orange.cgColor
            lastText = ""
        } else {
            print("[AUDIO] ------ start ------")
            AudioServer.share.startRecording(completion: { (isFinal, getText) in
                self.textView.text = getText
            })
            micphoneButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            pulsatingLayer.fillColor = UIColor.yellow.cgColor
        }
    }
    
    
}

extension SpeachTextVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        print("[GET] textViewDidChange: text = \(textView.text)")
    }
    
}


extension SpeachTextVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sentences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SentenceTableCell
        cell.sentence = sentences[indexPath.row]
        cell.selectionStyle = .none
        print("[TABLEVIEW] setup cell sentence = \(cell.sentence!)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension SpeachTextVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let approximateWidthOfTextView = view.frame.width - 40
        let sz = CGSize(width: approximateWidthOfTextView, height: 600)
        let atts = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        let estimateFrame = NSString(string: sentences[indexPath.row].string).boundingRect(with: sz, options: .usesLineFragmentOrigin, attributes: atts, context: nil)
        return estimateFrame.height + 50
    }
    

}


