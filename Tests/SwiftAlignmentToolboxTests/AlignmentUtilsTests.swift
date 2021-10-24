//
//  AlignmentUtilsTest.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 19.10.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge
import Accelerate

final class AlignmentUtilsTests: XCTestCase {
    func testOnsetTracker() {
        let onsets: [Float] = [0, 2, 1, 4, 3]
        // XCTAssertEqual(a[4], Float(4))
        var onsetTracker = OnsetTracker(uniqueOnsets: onsets)
        
        let perfOnsets = linSpace(start: -0.1, stop: 4.1, num: 100)
        
        var so: Float?
        for po in perfOnsets {
            so = onsetTracker(po)
            // print(onsetTracker.performedOnsets, onsetTracker.currentOnset)
            if so != nil{
                XCTAssertEqual(round(so!), round(po))
            }
        }
    }
    
    func testTimeMaps() {
        let indexToTimeScaleFactor: Float = 0.01
        let timeToIndexScaleFactor: Float = 1.0 / indexToTimeScaleFactor
        
        let sampleRate = 100
        let frameSize = 64
        // let framedSignalPath: String = "/Users/Carlos/Desktop/framed_signal.txt"
        let framedSignalURL = SampleData.numpyFramedSignalExample!
        let madmomFramedSignal: Matrix<Float> = csvToMatrix(url: framedSignalURL)!
        
        let spectrogramURL = SampleData.numpySpectrogramExample!
        let referenceFeatures: Matrix<Float> = csvToMatrix(url: spectrogramURL)!
        
        let ix2refMap = ConstantIndexToTimeMap(scaleFactor: indexToTimeScaleFactor
        )
        let ref2ixMap = ConstantTimeToIndexMap(
            scaleFactor: timeToIndexScaleFactor,
            maxIndex: referenceFeatures.rows
        )
        
        let warpingPathURL = SampleData.pythonWarpingPathExample!
        let pwp: Matrix<Float> = csvToMatrix(url: warpingPathURL)!
        let expectedTimes: Array<Float> = pwp[column: 1] * indexToTimeScaleFactor
        
        let oltw = OnlineTimeWarping(
            referenceFeatures: referenceFeatures,
            stepSize: 5,
            windowSize: 10,
            localDistance: "L1"
        )
        
        let processor = SpectrogramProcessor(frameSize: frameSize,
                                             window: "hanningPy",
                                             sampleRate: Float(sampleRate))
        
        var scoreFollower = OnlineAlignment(
            follower: oltw,
            processor: processor,
            indexToTimeMap: ix2refMap,
            timeToIndexMap: ref2ixMap
        )
        
        for i in 0..<madmomFramedSignal.rows {
            scoreFollower(frame: madmomFramedSignal[row: i])
            // warpingPath.append([i, oltw.currentPosition])
            XCTAssertEqual(expectedTimes[i], scoreFollower.currentTime)
            XCTAssertEqual(ref2ixMap(expectedTimes[i]), scoreFollower.currentPosition)
        }
    }
    
    func testLinearInterpolationTimeMaps() {
        let indices: [Int] =  [0,  2,  3,  6, 10]
        let times: [Float] = [10.0, 30.0, 50.0, 55.0, 97.4372]

        let newIndices: [Int] = Array(0..<11)
        
        let indexToTimeMap = LinearInterpolationIndexToTimeMap(
            refIndices: indices,
            indexTimes: times)
        let timeToIndexMap = LinearInterpolationTimeToIndexMap(
            indexTimes: times,
            refIndices: indices
        )
        
        let interpTimes: [Float] = newIndices.map { indexToTimeMap($0) }
        
        let interpIndices: [Int] = interpTimes.map { timeToIndexMap($0) }
        
        for (ni, ii) in zip(newIndices, interpIndices) {
            XCTAssertEqual(ni, ii)
        }
        
    }
    
}

