//
//  Extensions.swift
//  Beejee
//
//  Created by Vishal Bharam on 7/5/18.
//  Copyright © 2018 Vishal Bharam. All rights reserved.
//

import Foundation

extension Data {
    func convertToBytes() -> [Byte] {
        let count = self.count / MemoryLayout<Byte>.size
        var result = [Byte](repeating : 0, count : self.count)
        self.copyBytes(to: &result, count: count * MemoryLayout<Byte>.size)
        return result
    }
}

extension UInt16 {
    func twoBytes() -> [Byte] {
        var value : [Byte] = Array()
        value.append(Byte(self / UInt16(256)))
        value.append(Byte(self - (UInt16(value[0]) * UInt16(256))))
        return value
    }
}

