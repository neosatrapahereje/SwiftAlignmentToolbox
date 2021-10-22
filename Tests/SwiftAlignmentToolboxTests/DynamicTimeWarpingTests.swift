//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 22.10.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Accelerate
import Surge

final class DynamicTimeWarpingTests: XCTestCase {
    func testDTW() {
        let X: Matrix<Float> = csvToMatrix(url: SampleData.pythonDTWXExample!)!
        let Y: Matrix<Float> = csvToMatrix(url: SampleData.pythonDTWYExample!)!
        let pwp: Matrix<Float> = csvToMatrix(url: SampleData.pythonDTWPathExample!)!
        
        var pythonWarpingPath : [[Int]] = []
        
        for row in 0..<pwp.rows {
            let IntRow: [Int] = pwp[row: row].compactMap {Int($0)}
            pythonWarpingPath.append(IntRow)
        }
        
        let path: [[Int]]
        let dtwd: Float
        
        (path, dtwd) = dynamicTimeWarping(
            X: X,
            Y: Y,
            window: nil,
            localDistance: EuclideanDistance
        )
        XCTAssertEqual(677.1603, dtwd, accuracy: 1e-6)
        XCTAssertEqual(path, pythonWarpingPath)
    }
}
