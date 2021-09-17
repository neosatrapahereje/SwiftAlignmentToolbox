    import XCTest
    @testable import SwiftAlignmentToolbox

    final class SwiftAlignmentToolboxTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            XCTAssertEqual(SwiftAlignmentToolbox().text, "Hello, World!")
        }
    }

    final class MathUtilsTests: XCTestCase {
        func testMatrixTime() {
            // Test time to create a large matrix
            let rows: Int = 1000
            let columns: Int = 100
            var bigMatrix = Matrix<Float>(rows:rows, columns:columns, defaultValue:0.0)

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
        func testMatrixSlicing() {
            let rows: Int = 100
            let columns: Int = 10
            var bigMatrix = Matrix<Float>(rows:rows, columns:columns, defaultValue:0.0)
            
            let newValues = Matrix<Float>(array: [[1.0], [2.0], [3.0], [4.0]])
            
            bigMatrix[0..<newValues.rows, 7] = newValues
            
            for i in Array(0..<newValues.rows) {
                XCTAssertEqual(bigMatrix[i, 7],  newValues[i, 0])
            }
        }
        func testMatrixCodec() {
            let matrix = Matrix<Float>(array: [[1.0], [2.0], [3.0], [4.0]])
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(matrix){
                print("encoded!")
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(Matrix<Float>.self, from: encoded) {
                    print("decoded grid \(decoded.grid[2])")
                    XCTAssertEqual(matrix.grid,  decoded.grid)
                } else {
                    print("Failed decoding")
                    XCTAssertEqual(true, false)
                }
            }
        }
    }

    final class AlignmentToolsTest: XCTestCase {
        func testOnlineTimeWarping() {
            let dummy: Int = 1
            XCTAssertEqual(dummy, 1)
        }
    }

