//
//  AlignmentUtils.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 19.10.21.
//

import Foundation
import Accelerate
import Surge

public struct OnsetTracker {
    // Track the unique (onset) positions in performed time units (e.g., seconds)
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
        // TODO: ensure that the list of onsets is unique?
        self.uniqueOnsets = uniqueOnsets.sorted()
        self.maxIdx = uniqueOnsets.count - 1
    }
    
    public mutating func callAsFunction(_ refTime: Float) -> Float? {
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

public class IndexToTimeMap {
    // Base class for RefTimeMaps
    public func callAsFunction(_ index: Int) -> Float {
        return Float(index)
    }
}

public class TimeToIndexMap {
    // Base class for InvRefTimeMaps
    public func callAsFunction(_ time: Float) -> Int {
        return Int(time)
    }
}

// This is probably too overengineered... ;)
public class IndexToTimeMapWraper: IndexToTimeMap {
    let map: (Int) -> Float
    public init(map: @escaping (Int) -> Float) {
        self.map = map
    }
    public override func callAsFunction(_ index: Int) -> Float {
        return self.map(index)
    }
}

public class ConstantIndexToTimeMap: IndexToTimeMap {
    let scaleFactor: Float
    
    public init(scaleFactor: Float) {
        self.scaleFactor = scaleFactor
    }
    
    public override func callAsFunction(_ index: Int) -> Float {
        let refTime: Float = Float(index) * self.scaleFactor
        return refTime
    }
}

public class ConstantTimeToIndexMap: TimeToIndexMap {
    let scaleFactor: Float
    var maxIndex: Int
    var minIndex: Int
    
    public init(scaleFactor: Float, minIndex: Int = 0, maxIndex: Int) {
        self.scaleFactor = scaleFactor
        self.minIndex = minIndex
        self.maxIndex = maxIndex
    }
    
    public override func callAsFunction(_ time: Float) -> Int {
        let index: Int = Int(round(time * self.scaleFactor))
        if index < self.minIndex {
            return self.minIndex
        } else if index > maxIndex {
            return self.maxIndex
        }
        return index
    }
}

public class LinearInterpolationIndexToTimeMap: IndexToTimeMap {
    
    let interpfunc: LinearInterpolation
    
    public init(refIndices: [Int], indexTimes: [Float]) {
        
        self.interpfunc = LinearInterpolation(
            x: refIndices.map { Float($0)},
            y: indexTimes
        )
    }
    public override func callAsFunction(_ index: Int) -> Float {
        let time: Float = self.interpfunc(Float(index))
        return time
    }
}

public class LinearInterpolationTimeToIndexMap: TimeToIndexMap {
    var maxIndex: Int
    var minIndex: Int
    var maxTime: Float
    var minTime: Float
    let interpfunc: LinearInterpolation
    public init(indexTimes: [Float], refIndices: [Int]) {
            
        self.maxIndex = refIndices.max()!
        self.minIndex = refIndices.min()!
        self.maxTime = indexTimes.max()!
        self.minTime = indexTimes.min()!
        
        self.interpfunc = LinearInterpolation(
            x: indexTimes,
            y: refIndices.map { Float($0) }
        )
    }
    
    public override func callAsFunction(_ time: Float) -> Int {
        if time >= self.maxTime {
            return self.maxIndex
        } else if time <= self.minTime {
            return self.minIndex
        } else {
            let idx: Int = Int(round(self.interpfunc(time)))
            return idx
        }
    }
}
