//
//  Sentence.swift
//  speach2txt
//
//  Created by Xin Zou on 2/3/18.
//  Copyright © 2018 Xin Zou. All rights reserved.
//

import Foundation
import Unbox

enum KeysForDB: String {
    case timestamp = "timestamp"
    case sentensString = "string"
}

struct Sentence: Unboxable {
    
    let timestamp: TimeInterval
    let string: String
    
    init(timestamp t: TimeInterval = Date().timeIntervalSince1970, string s: String) {
        self.timestamp = t
        self.string = s
    }
    
    init(unboxer: Unboxer) throws {
        self.timestamp = (try? unboxer.unbox(key: KeysForDB.timestamp.rawValue)) ?? Date().timeIntervalSince1970
        self.string = (try? unboxer.unbox(key: KeysForDB.sentensString.rawValue)) ?? ""
    }
    
}
