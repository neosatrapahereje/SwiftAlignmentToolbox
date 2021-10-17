//
//  SpectrogramTests.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 02.10.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge
import Accelerate

final class SpectrogramTest: XCTestCase {
    func testFFT() {
        // Test Swift's FFT vs Python (stft in Madmom)
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
        let outputImaginaryPython: Array<Float> = [-0        , -4.302039  , -0.08847175, -2.9968126 , -1.3795012 ,
                                                    -3.0262563 , -2.310491  ,  0.5497931 ]
        
        computeFFT(
            inputReal: inputReal,
            inputImaginary: inputImaginary,
            outputReal: &outputReal,
            outputImaginary: &outputImaginary,
            frameSize: frameSize)
        
        let absErrorReal = zip(outputReal, outputRealPython).map {abs($0 - $1)}
        
        for err in absErrorReal {
            XCTAssertTrue(err < tol)
        }
        
        let absErrorImaginary = zip(outputImaginary, outputImaginaryPython).map {abs($0 - $1)}
        
        for err in absErrorImaginary {
            XCTAssertTrue(err < tol)
        }
    }
    
    func testComputeMagnitudeSpectrogram() {
        // Test magnitude spectrogram vs. Python (madmom)
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
        let spectrogramPython: Array<Float> = [1.2900565, 4.4219136, 1.4745837, 3.2638814, 1.4218707, 3.6456287,
                                              5.8123736, 3.4832466]
        
        // Magnitude spectrogram
        var spectrogram = Array(repeating: Float(0.0), count: frameSize/2)
        
        computeFFT(
            inputReal: inputReal,
            inputImaginary: inputImaginary,
            outputReal: &outputReal,
            outputImaginary: &outputImaginary,
            frameSize: frameSize)
        computeMagnitudeSpectrogram(fftOutputReal: &outputReal, fftOutputImaginary: &outputImaginary, spectrogram: &spectrogram, frameSize: 8)
        
        let absError = zip(spectrogram, spectrogramPython).map {abs($0 - $1)}
        
        for err in absError {
            XCTAssertTrue(err < tol)
        }
        
        
    }
    func testComputeFeatures() {
        // Test to see the time that each of the steps for computing a spectrogram takes
        let start = DispatchTime.now()
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
    
    func testHanningWindow() {
        let tol: Float = 1e-6
        let pythonHanningWindow: Array<Float> = [0        , 0.11697778, 0.41317591, 0.75      , 0.96984631,
                                          0.96984631, 0.75      , 0.41317591, 0.11697778, 0        ]
        
        let swiftHanningWindow: Array<Float> = numpyHanningWindow(count: 10)
        
        let absError = zip(pythonHanningWindow, swiftHanningWindow).map {abs($0 - $1)}
        
        for err in absError {
            XCTAssertTrue(err < tol)
        }
    }
    
    func testHammingWindow() {
        // Test windows
        let tol: Float = 1e-6
        let pythonHammingWindow: Array<Float> = [0.08      , 0.18761956, 0.46012184, 0.77      , 0.97225861,
                                                0.97225861, 0.77      , 0.46012184, 0.18761956, 0.08      ]
        
        let swiftHammingWindow: Array<Float> = numpyHammingWindow(count: 10)
        
        let absError = zip(pythonHammingWindow, swiftHammingWindow).map {abs($0 - $1)}
        
        for err in absError {
            XCTAssertTrue(err < tol)
        }
    }
    
    func testBlackmanWindow() {
        // Test windows
        let tol: Float = 1e-6
        let pythonBlackmanWindow: Array<Float> = [-1.38777878e-17,  5.08696327e-02,  2.58000502e-01,  6.30000000e-01,
                                                  9.51129866e-01,  9.51129866e-01,  6.30000000e-01,  2.58000502e-01,
                                                  5.08696327e-02, -1.38777878e-17]
        
        let swiftBlackmanWindow: Array<Float> = numpyBlackmanWindow(count: 10)
        
        let absError = zip(pythonBlackmanWindow, swiftBlackmanWindow).map {abs($0 - $1)}
        
        for err in absError {
            XCTAssertTrue(err < tol)
        }
    }
    
    func testSpectrogramPipeline() {
        
        let sampleRate = 100
        let frameSize = 64
        let hopSize = 32
        
        let signalURL = SampleData.numpySignalExample!
        let sigdata: Matrix<Float> = csvToMatrix(url: signalURL)!
        let signal: Signal = Signal(data: sigdata, sampleRate: sampleRate)
        
        // let framedSignalPath: String = "/Users/Carlos/Desktop/framed_signal.txt"
        let framedSignalURL = SampleData.numpyFramedSignalExample!
        let madmomFramedSignal: Matrix<Float> = csvToMatrix(url: framedSignalURL)!
        
        let spectrogramURL = SampleData.numpySpectrogramExample!
        let madmomSpectrogram: Matrix<Float> = csvToMatrix(url: spectrogramURL)!
        
        let framedSignal: FramedSignal = FramedSignal(signal: signal,
                                                      frameSize: frameSize,
                                                      hopSize: hopSize)
        
        for row in 0..<madmomFramedSignal.rows {
            XCTAssertEqual(madmomFramedSignal[row: row], framedSignal[row])
        }
        
        let swiftSpectrogram = Spectrogram(framedSignal: framedSignal,
                                           window: "hanningPy")
        XCTAssertEqual(swiftSpectrogram.spectrogram.columns, madmomSpectrogram.columns)
        XCTAssertEqual(swiftSpectrogram.spectrogram.rows, madmomSpectrogram.rows)
    }
}
