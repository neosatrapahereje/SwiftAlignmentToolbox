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
    
    final class SignalTest: XCTestCase {
        func testSignal() {
            var data: Array<Float> = Array(repeating: 0, count: Int.random(in: 500...1000))
            
            for i in 0..<data.count {
                data[i] = Float.random(in: -100...100)
            }
            
            let signal = Signal(
                data: data,
                sampleRate: 100,
                norm: false,
                gain: 0
            )
            
            for i in 0..<data.count {
                XCTAssertEqual(signal[i], data[i])
            }
            
            let startIdx: Int = 30
            let endIdx: Int = 70
            
            let sigSlice = signal[startIdx..<endIdx]
            for i in 0..<(endIdx - startIdx) {
                XCTAssertEqual(sigSlice[i + startIdx], data[i + startIdx])
            }
        }
        
        func testSignalNorm() {
            var data: Array<Float> = Array(repeating: 0, count: Int.random(in: 500...1000))
            
            for i in 0..<data.count {
                data[i] = Float.random(in: -100...100)
            }
            
            let signal = Signal(
                data: data,
                sampleRate: 100,
                norm: true,
                gain: 0
            )
            
            let startIdx: Int = 30
            let endIdx: Int = 400
            let dmax: Float = max(
                data.max()!,
                abs(data.min()!)
            )
            
            let sigSlice = signal[startIdx..<endIdx]
            for i in 0..<(endIdx - startIdx) {
                XCTAssertEqual(sigSlice[i + startIdx], data[i + startIdx] / dmax)
            }
        }
        
        func testFramedSignal() {
            var data: Array<Float> = Array(repeating: 0, count: 510)
            
            for i in 0..<data.count {
                data[i] = Float.random(in: -100...100)
            }
            
            let signal = Signal(
                data: data,
                sampleRate: 100,
                norm: false,
                gain: 0
            )
            
            let frameSize: Int = 50
            let hopSize: Int = 25
            
            let numFullFrames: Int = data.count / hopSize
            let numFrames: Int = numFullFrames + 1
            let framedSignal = FramedSignal(
                signal: signal,
                frameSize: frameSize,
                hopSize: hopSize,
                origin: "right"
            )
            
            XCTAssertEqual(framedSignal.count, numFrames)
            
            for i in 0..<(numFullFrames - 1)  {
                for (fv, tv) in zip(framedSignal[i], data[i*hopSize..<i*hopSize + frameSize]) {
                    XCTAssertEqual(fv, tv)
                }
            }
            
            for (fv, tv) in zip(framedSignal[numFrames - 1], data[500..<510]) {
                XCTAssertEqual(fv, tv)
            }
            
            for fv in framedSignal[numFrames-1][10..<frameSize] {
                XCTAssertEqual(fv, 0.0)
            }
        }
    }

