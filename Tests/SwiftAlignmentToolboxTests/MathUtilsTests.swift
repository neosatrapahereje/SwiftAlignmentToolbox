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

final class MathUtilsTests: XCTestCase {
    func testSinc() {
        let tol: Float = 1e-6
        let x: Array<Float> = [-1.22795046,  2.36736427, -0.76388198,  0.42896561,  0.96992622,
                               -0.24800455,  0.80682479,  0.63854348, -1.45518737, -0.34262863,
                               -0.60116594, -0.45922278, -0.25039278,  0.05933658, -1.06086305,
                               -0.15171991]
        let sincRes: Array<Float> = sinc(x)
        let sincResPython: Array<Float> = [
            -0.17017003,  0.1229526 ,  0.28152534,  0.72363999,  0.03096015,
            0.90185309,  0.22499793,  0.45201704, -0.21657738,  0.81777727,
            0.50296989,  0.6874693 ,  0.90001255,  0.99421852, -0.05702232,
            0.96256318
        ]
        
        let absError = zip(sincRes, sincResPython).map {abs($0 - $1)}
        
        for err in absError {
            XCTAssertTrue(err < tol)
        }
        
    }
    
    func testNormalizeArray() {
        let signal: Array<Float> = Vector<Float>.random(count: 1000).scalars
        let scaling: Float = Float(1) / (Surge.max(Surge.abs(signal)) + 1e-10)
        let normalizedSignalExpected: Array<Float> = signal.map{$0 * scaling}
        let normalizedSignalActual = normalize(signal: signal)
        XCTAssertEqual(normalizedSignalActual, normalizedSignalExpected)
    }
}
