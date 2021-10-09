//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 02.10.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge

final class SpectrogramTest: XCTestCase {
    func testFFT() {
        let frameSize: Int = 16
        let tol: Float = 1e-6
        let inputReal: Array<Float> = [-1.22795046,  2.36736427, -0.76388198,  0.42896561,  0.96992622,
                                       -0.24800455,  0.80682479,  0.63854348, -1.45518737, -0.34262863,
                                       -0.60116594, -0.45922278, -0.25039278,  0.05933658, -1.06086305,
                                       -0.15171991]
        let inputImaginary = Array(repeating: Float(0.0), count: frameSize) // imaginary part of input to FFT
        var outputReal = Array(repeating: Float(0.0), count: frameSize) // real part of FFT output
        var outputImaginary = Array(repeating: Float(0.0), count: frameSize) // imaginary part of FFT output

        // The output from the python functions
        let outputRealPython: Array<Float> = [-1.2900565,   1.0226327,  -1.47192727,  1.29307269, -0.34451821,  2.03282584,
                                   -5.33341527, -3.43958358, -5.87532464, -3.43958358, -5.33341527,  2.03282584,
                                   -0.34451821,  1.29307269, -1.47192727,  1.0226327]
        
        computeFFT(
            inputReal: inputReal,
            inputImaginary: inputImaginary,
            outputReal: &outputReal,
            outputImaginary: &outputImaginary,
            frameSize: frameSize)
        
        let absError = zip(outputReal, outputRealPython).map {abs($0 - $1)}
        
        for err in absError {
            XCTAssertTrue(err < tol)
            
        }
    }
    func testComputeFeatures() {
        let start = DispatchTime.now()
        // let path: String = "/Users/carlos/Documents/RITMO/MusicLab2020/ScoreFollowing/data/DSQ_tracks/kdf_c14_mono.wav"
        // let (audioFile, sampleRate) = loadAudioFile(path: path)
        let (audioFile, sampleRate) = loadAudioFile(url: SampleData.audioExampleMonoURL!)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
        print("Time load audio file \(timeInterval) seconds")

        let start_s = DispatchTime.now()
        let signal = Signal(data: audioFile,
                            sampleRate: Int(sampleRate))
        print("created signal")
        let end_s = DispatchTime.now()
        let nanoTime_s = end_s.uptimeNanoseconds - start_s.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval_s = Double(nanoTime_s) / 1_000_000_000 // Technically could overflow for long running tests
        print("Time to create signal \(timeInterval_s) seconds")

        let start_f = DispatchTime.now()
        let frameSize: Int = 2048 * 2//Int(sampleRate * 0.1)
        let hopSize: Int = Int(frameSize) / 2
        let framedSignal = FramedSignal(
            signal: signal,
            frameSize: frameSize,
            hopSize: hopSize)
        let end_f = DispatchTime.now()
        let nanoTime_f = end_f.uptimeNanoseconds - start_f.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval_f = Double(nanoTime_f) / 1_000_000_000 // Technically could overflow for long running tests
        print("Time to frame signal \(timeInterval_f) seconds")

        // let processor = SpectrogramProcessor(frameSize: frameSize, includeNyquist: false)
        let start_p = DispatchTime.now()

        let spectrogram = Spectrogram(framedSignal: framedSignal)
        print("numFFTBins \(spectrogram.numFFTBins)")
        print("numFrames \(framedSignal.numFrames)")
        
        let end_p = DispatchTime.now()
        let nanoTime_p = end_p.uptimeNanoseconds - start_p.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval_p = Double(nanoTime_p) / 1_000_000_000 // Technically could overflow for long running tests
        print("Time to compute spectrogram \(timeInterval_p) seconds")
        XCTAssertEqual(spectrogram.numFFTBins, spectrogram.spectrogram.columns)
    }
}
