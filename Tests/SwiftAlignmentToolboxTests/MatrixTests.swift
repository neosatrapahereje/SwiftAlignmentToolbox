//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 22.09.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge

final class MatrixTests: XCTestCase {
    /*
    func testMatrixTime() {
        // Test time to create a large matrix
        let rows: Int = 1000
        let columns: Int = 100
        var bigMatrix = Matrix<Float>(rows:rows, columns:columns, repeatedValue:0.0)

        let start = DispatchTime.now()
        for i in Array<Int>(0..<rows){
            for j in Array<Int>(0..<columns) {
                bigMatrix[i, j] = Float.random(in: 0.1...0.99)
            }
        }
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
        print("Time to evaluate problem \(timeInterval) seconds")
    }
 */
    /*
    func testMatrixSlicing() {
        let rows: Int = 100
        let columns: Int = 10
        var bigMatrix = Matrix<Float>(rows:rows, columns:columns, repeatedValue:0.0)
        
        let newValues = [[1.0], [2.0], [3.0], [4.0]]
        
        bigMatrix[column: 7] = newValues
        
        for i in Array(0..<newValues.rows) {
            XCTAssertEqual(bigMatrix[i, 7],  newValues[i, 0])
        }
    }
     */
    func testMatrixCodec() {
        let matrix = Matrix<Float>([[1.0], [2.0], [3.0], [4.0]])
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(matrix){
            print("encoded!")
            print(encoded)
            
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(Matrix<Float>.self, from: encoded) {
                XCTAssertEqual(matrix,  decoded)
            } else {
                print("Failed decoding")
                XCTAssertEqual(true, false)
            }
        }
    }
    
    func testMatrixSaving() {
        let matrix: Matrix<Float> = Matrix<Float>.randomNormal(rows:10, columns:7)
        // It takes 1.637 seconds for 1000x200 matrix
        // It takes 31+ seconds for 10000x200 matrix
        
        let path: String = "/tmp/swift_testMatrixSaving.swz"
        
        matrix.saveToFile(path: path)
        
        let reloadedMatrix: Matrix<Float> = readMatrixFromFile(path: path)
        
        XCTAssertEqual(reloadedMatrix, matrix)
        // Remove temp file
        let fileManager = FileManager.default
    
        if fileManager.fileExists(atPath: path) {
            
            do {
                try fileManager.removeItem(atPath: path)
            } catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
    
    func testMatrixSavingFromConfig() {
        // This test can last a while...
        // The point is to see if it can save large matrices (the old method cannot do this)
        
        let matrix: Matrix<Float> = Matrix<Float>.randomNormal(rows:10000, columns:7000)
        let path: String = "/tmp/swift_testMatrixSavingFromConfig.json"
        
        saveMatrix(matrix: matrix, path: path)
        
        let reloadedMatrix: Matrix<Float> = readMatrixFromConfig(path: path)
        XCTAssertEqual(reloadedMatrix, matrix)
        // Remove temp file
        let fileManager = FileManager.default
    
        if fileManager.fileExists(atPath: path) {
            
            do {
                try fileManager.removeItem(atPath: path)
            } catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
}
