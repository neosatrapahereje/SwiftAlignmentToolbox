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
}
