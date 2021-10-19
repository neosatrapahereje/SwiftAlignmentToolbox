//
//  AlignmentUtils.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 19.10.21.
//

import Foundation

public struct OnsetTracker {
    public let uniqueOnsets: [Float]
    public var currentIdx: Int = 0
    public var performedOnsets: [Float] = []
    let maxIdx: Int
    
    public var currentOnset: Float {
        get {
            if self.currentIdx < self.maxIdx && self.currentIdx >= 0{
                return self.uniqueOnsets[self.currentIdx]
            } else if self.currentIdx == 0 {
                return self.uniqueOnsets[0]
            } else {
                return self.uniqueOnsets[self.maxIdx]
            }
        }
    }
    
    public init(uniqueOnsets: [Float]) {
        self.uniqueOnsets = uniqueOnsets.sorted()
        self.maxIdx = uniqueOnsets.count - 1
    }
    
    mutating func callAsFunction(_ refTime: Float) -> Float? {
        var scoreOnset: Float? = nil
        if refTime >= self.currentOnset {
            if !self.performedOnsets.contains(self.currentOnset) {
                scoreOnset = self.currentOnset
                self.performedOnsets.append(self.currentOnset)
                self.currentIdx += 1
            }
        }
        return scoreOnset
    }
}
