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


final class MiscUtilsTest : XCTestCase {
    func testSaveCompressedData() {
        let array : [[Float]] = [[1.1, 3.7] , [2.5, 6.4], [7.8, 8.3]]
        let matrix: Matrix<Float> = Matrix(array)

        print(matrix)

        let path: String = "/tmp/test_compression.swz"
        if let encodedData = try? JSONEncoder().encode(matrix) {
            writeToFile(data: encodedData,
                        fileName: path,
                        compress: true)
            let fileurl = URL(fileURLWithPath: path)
            // check that the file was saved
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileurl.path))
        }
        
        let readData = readFromFile(fileName: path)!
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Matrix<Float>.self, from: readData) {
            print("decoded grid \(decoded.grid[2])")
            XCTAssertEqual(matrix.grid,  decoded.grid)
        } else {
            print("Failed decoding")
            XCTAssertEqual(true, false)
        }
    }
    
    /*
    func testSecureInput() {
        secureInput(forType: Float.self)
    }
     */
    
    func testCsvToMatrix() {
        
        let url: URL = SampleData.numpySpectrogramExample!
        let fullMatrix = csvToMatrix(url: url)
        let skipMatrix = csvToMatrix(url: url, skipRows: 2)
        
        XCTAssertEqual(fullMatrix![row: 2], skipMatrix![row: 0])
        let tMatrix: [[Float]] = Surge.transpose(skipMatrix!).toArray()
        print(tMatrix)
        
    }
}

