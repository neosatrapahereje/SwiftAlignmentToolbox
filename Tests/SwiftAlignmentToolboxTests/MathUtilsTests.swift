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
    
    func testinterpolationSearch() {
        let A: Array<Float> = [0, 1, 2, 3]
        let keys: Array<Float> = [0.5, 1.5, 3.3, 9.4, 7.8, 0.3]
        let ix: Array<Int> = interpolationSearch(A, keys)
    }
    
    func testargsort() {
        let A: [Int] = [4, 6, 3, 8, 17, 99, 31]
        let sortedIdxs: [Int] = [2, 0, 1, 3, 4, 6, 5]
        let sortIdxs = argsort(A)
        XCTAssertEqual(sortedIdxs, sortIdxs)
    }
    
    func testLiniearInterpolation() {
        let x: [Float] = [-1.85050346, -1.13927632, -0.86575633, -0.63382861, -0.48608938,
                           -0.36932539, -0.15150169, -0.00838228,  0.98403264,  2.20056371]
        let y: [Float] = [-0.51561665, -1.36980785,  0.28948061, -2.57148473,  0.78154492,
                           -1.11057286, -0.4879139 ,  0.87755467,  0.83441429, -0.95737641]
        
        let newx: [Float] = [-0.38721324, -1.66905079, -1.85050346,  1.08275082, -0.60539559,
                              -0.9608862 ,  1.67969354, -0.54700108,  0.62240629,  0.95025464,
                               0.27323915, -0.63581996,  0.77829357,  0.16472823, -1.60099685]
        
        let pythonInterp: [Float] = [-0.82070681, -0.7335432 , -0.51561665,  0.68901536, -1.92618039,
                                      -0.28761756, -0.19020296, -0.6008824 ,  0.85013423,  0.83588263,
                                       0.86531256, -2.54692024,  0.84335779,  0.87002954, -0.81527668]
        
        let interpfunc = LinearInterpolation(x: x, y: y)
        let results = interpfunc(newx)
        
        for (sv, pv) in zip(results, pythonInterp) {
            XCTAssertEqual(sv, pv, accuracy:1e-4)
        }
    }
}
