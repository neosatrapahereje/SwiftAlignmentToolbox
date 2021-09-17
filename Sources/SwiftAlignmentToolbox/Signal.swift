//
//  Signal.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 16.09.21.
//

import Foundation

let FRAME_SIZE: Int = 2048
let HOP_SIZE: Int = 441
let ORIGIN = 0
let END_OF_SIGNAL: Int? = nil
let NUM_FRAMES: Int? = nil

func signalFrame(signal: Array<Float>, index: Int, frameSize: Int, hopSize: Int, origin: Int = 0, pad: Float = 0.0) -> ArraySlice<Float> {
    
    // Length of the signal
    let numSamples: Int = signal.count
    
    //
    let refSample: Int = index * hopSize
    
    var start: Int = ((refSample - frameSize) / 2) - origin
    
    var stop: Int = start + frameSize
    
    if start >= 0 && stop <= numSamples {
        return signal[start..<stop]
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
        for i in Array(0..<(frameSize - right - left)) {
            frame[left + i] = signal[signalLeft + i]
        }
        return ArraySlice(frame)
    }
}

func normalize(signal: Array<Float>) -> Array<Float> {
    
    let scaling: Float = signal.map{abs($0)}.max()!
    let normalizedSignal: Array<Float> = signal.map{$0 / scaling}
    return normalizedSignal
}

struct Signal: Codable {
    let data: Array<Float>
    let count: Int
    let sampleRate: Int
    // For the moment assume that the signal is downmixed to mono
    // let numChannels: Int
    // let start: Float?
    // let stop: Float?
    let norm: Bool
    let gain: Float
    
    init(
        data: Array<Float>,
        sampleRate: Int,
        // numChannels: Int,
        // start: Float? = nil,
        // stop: Float? = nil,
        norm: Bool = false,
        gain: Float = 0.0
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
struct framedSignal<Float: Codable>: Codable {
    let signal: Array<Float>
    let frameSize: Int
    let hopSize: Int
    // let origin: Int?
    // let end: Int?

    init(signal: Array<Float>,
         frameSize: Int = FRAME_SIZE,
         hopSize: Int = HOP_SIZE) {
        self.signal = signal
        self.frameSize = frameSize
        self.hopSize = hopSize
        
    }
    
}
