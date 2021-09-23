//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 23.09.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge

final class SignalTest: XCTestCase {
    func testSignal() {
        var data: Array<Float> = Array(repeating: 0, count: Int.random(in: 500...1000))
        
        for i in 0..<data.count {
            data[i] = Float.random(in: -100...100)
        }
        
        let signal = Signal(
            data: data,
            sampleRate: 100,
            norm: false,
            gain: 0
        )
        
        for i in 0..<data.count {
            XCTAssertEqual(signal[i], data[i])
        }
        
        let startIdx: Int = 30
        let endIdx: Int = 70
        
        let sigSlice = signal[startIdx..<endIdx]
        for i in 0..<(endIdx - startIdx) {
            XCTAssertEqual(sigSlice[i + startIdx], data[i + startIdx])
        }
    }
    
    func testSignalNorm() {
        var data: Array<Float> = Array(repeating: 0, count: Int.random(in: 500...1000))
        
        for i in 0..<data.count {
            data[i] = Float.random(in: -100...100)
        }
        
        let signal = Signal(
            data: data,
            sampleRate: 100,
            norm: true,
            gain: 0
        )
        
        let startIdx: Int = 30
        let endIdx: Int = 400
        let dmax: Float = max(
            data.max()!,
            abs(data.min()!)
        )
        
        let sigSlice = signal[startIdx..<endIdx]
        for i in 0..<(endIdx - startIdx) {
            XCTAssertEqual(sigSlice[i + startIdx], data[i + startIdx] / dmax, accuracy: 1e-5)
        }
    }
    
    func testFramedSignal() {
        var data: Array<Float> = Array(repeating: 0, count: 510)
        
        for i in 0..<data.count {
            data[i] = Float.random(in: -100...100)
        }
        
        let signal = Signal(
            data: data,
            sampleRate: 100,
            norm: false,
            gain: 0
        )
        
        let frameSize: Int = 50
        let hopSize: Int = 25
        
        let numFullFrames: Int = data.count / hopSize
        let numFrames: Int = numFullFrames + 1
        var framedSignal = FramedSignal(
            signal: signal,
            frameSize: frameSize,
            hopSize: hopSize,
            origin: "right"
        )
        
        XCTAssertEqual(framedSignal.count, numFrames)
        
        for i in 0..<(numFullFrames - 1)  {
            for (fv, tv) in zip(framedSignal[i], data[i*hopSize..<i*hopSize + frameSize]) {
                XCTAssertEqual(fv, tv)
            }
        }
        
        for (fv, tv) in zip(framedSignal[numFrames - 1], data[500..<510]) {
            XCTAssertEqual(fv, tv)
        }
        
        for fv in framedSignal[numFrames-1][10..<frameSize] {
            XCTAssertEqual(fv, 0.0)
        }
    }
}
