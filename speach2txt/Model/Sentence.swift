//
//  Sentence.swift
//  speach2txt
//
//  Created by Xin Zou on 2/3/18.
//  Copyright © 2018 Xin Zou. All rights reserved.
//

import Foundation
import Unbox

struct Sentence {
    
    let timestamp: TimeInterval
    let string: String
    
    init(timestamp t: TimeInterval, string s: String) {
        self.timestamp = t
        self.string = s
    }
    
}
