//
//  Signal.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 16.09.21.
//

import Foundation

// Default values
public let SAMPLE_RATE: Int? = nil
public let NUM_CHANNELS: Float? = nil
public let FRAME_SIZE: Int = 2048
public let HOP_SIZE: Int = 441
public let ORIGIN = 0
public let END_OF_SIGNAL: Int? = nil
public let NUM_FRAMES: Int? = nil
public let GAIN: Float = 0.0
public let NORM: Bool = false


public struct Signal: Codable {
    public let data: Array<Float>
    public let count: Int
    public let sampleRate: Int
    // For the moment assume that the signal is downmixed to mono
    // let numChannels: Int
    // let start: Float?
    // let stop: Float?
    public let norm: Bool
    public let gain: Float
    
    init(
        data: Array<Float>,
        sampleRate: Int,
        // numChannels: Int,
        // start: Float? = nil,
        // stop: Float? = nil,
        norm: Bool = NORM,
        gain: Float = GAIN
    ) {
        self.sampleRate = sampleRate
        // self.numChannels = numChannels
        // self.start = start
        // self.stop = stop
        self.norm = norm
        self.gain = gain
        
        if self.norm {
            self.data = normalize(signal: data)
        } else {
            self.data = data
        }
        self.count = self.data.count
    }
    // TODO: What other subscript cases are there?
    subscript(index: Int) -> Float {
        return self.data[index]
    }
    subscript(range: Range<Int>) -> ArraySlice<Float> {
        return self.data[range]
    }
}


public struct FramedSignal {
    public let signal: Signal
    public let frameSize: Int
    public let hopSize: Int
    public let numFrames: Int
    public let frameRate: Float
    public let count: Int // for convenience
    let origin: Int

    public init(
        signal: Signal,
        frameSize: Int = FRAME_SIZE,
        hopSize: Int = HOP_SIZE,
        origin: String = "center"
    ) {
        self.signal = signal
        self.frameSize = frameSize
        self.hopSize = hopSize
        self.numFrames = Int(ceil(Float(self.signal.count) / Float(self.hopSize)))
        self.count = self.numFrames
        self.frameRate = Float(self.signal.sampleRate) / Float(self.hopSize)
        
        switch origin {
        case "center", "offline":
            self.origin = 0
        case "left", "past", "online":
            self.origin = (frameSize - 1) / 2
        case "right", "future", "stream":
            self.origin = -(frameSize / 2)
        default:
            self.origin = -(frameSize / 2)
        }

    }

    public init(
        signal: Array<Float>,
        sampleRate: Int,
        norm: Bool = NORM,
        gain: Float = GAIN,
        frameSize: Int = FRAME_SIZE,
        hopSize: Int = HOP_SIZE,
        origin: String = "center"
    ) {
        self.signal = Signal(
            data: signal,
            sampleRate: sampleRate,
            norm: norm,
            gain: gain
            )
        self.frameSize = frameSize
        self.hopSize = hopSize
        self.numFrames = Int(ceil(Float(self.signal.count) / Float(self.hopSize)))
        self.count = self.numFrames
        self.frameRate = Float(self.signal.sampleRate) / Float(self.hopSize)
        
        switch origin {
        case "center":
            self.origin = 0
        case "left":
            self.origin = (frameSize - 1) / 2
        case "right":
            self.origin = -(frameSize / 2)
        default:
            self.origin = (frameSize - 1) / 2
        }

    }
    
    public subscript(index: Int) -> Array<Float> {
        get {
            assert(indexIsValid(index: index), "Index out of range")
            // Is it worst to "create" a new variable than to duplicate the code?
            let idx: Int
            if index < 0 {
                idx = index + self.numFrames
            } else{
                idx = index
            }
            return signalFrame(
                signal: self.signal.data,
                index: idx,
                frameSize: self.frameSize,
                hopSize: self.hopSize,
                origin: self.origin
            )
        }
    }
    
    public func indexIsValid(index: Int) -> Bool {
        if index < 0 {
            return index + self.numFrames < self.numFrames
        } else {
            return index < self.numFrames
        }
    }
}


public func signalFrame(
    signal: Array<Float>,
    index: Int,
    frameSize: Int,
    hopSize: Int,
    origin: Int = 0,
    pad: Float = 0.0
) -> Array<Float> {
    
    // Length of the signal
    let numSamples: Int = signal.count
    
    //
    let refSample: Int = index * hopSize
    
    var start: Int = refSample - (frameSize / 2) - origin
    
    var stop: Int = start + frameSize
    
    if start >= 0 && stop <= numSamples {
        return Array(signal[start..<stop])
    } else {
        // Would this be the right way to do this?
        var left: Int = 0
        var right: Int = 0
        var frame: Array<Float> = Array(repeating: pad, count: frameSize)
        
        if start < 0 {
            left = min(stop, 0) - start
            start = 0
        }
        
        if stop > numSamples {
            right = stop - max(start, numSamples)
            stop = numSamples
        }
        
        let signalLeft : Int = min(start, numSamples)
        // let signalRight: Int = max(stop, 0)
        for i in 0..<(frameSize - right - left) {
            frame[left + i] = signal[signalLeft + i]
        }
        return frame
    }
}

public func normalize(signal: Array<Float>) -> Array<Float> {
    // Normalize signal
    let scaling: Float = signal.map{abs($0)}.max()!
    let normalizedSignal: Array<Float> = signal.map{$0 / scaling}
    return normalizedSignal
}

public func rescale(signal: Array<Float>) -> Array<Float>{
    // Rescale the signal to  range [-1, 1]
    let normalizedSignal: Array<Float> = signal.map{$0 / Float.greatestFiniteMagnitude}
    return normalizedSignal
}
