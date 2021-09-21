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
    
    final class MatrixTests: XCTestCase {
        /*
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
     */
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
                print(encoded)
                
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
        
        func testMatrixSaving() {
            let array : [[Float]] = [[1.1, 3.7] , [2.5, 6.4], [7.8, 8.3]]
            let matrix: Matrix<Float> = Matrix(array: array)
            
            let path: String = "/tmp/swift_testMatrixSaving.swz"
            
            matrix.saveToFile(path: path)
            
            let reloadedMatrix: Matrix<Float> = readMatrixFromFile(path: path)
            print(reloadedMatrix.grid)
            
            XCTAssertEqual(reloadedMatrix.rows, matrix.rows)
            XCTAssertEqual(reloadedMatrix.columns, matrix.columns)
            XCTAssertEqual(reloadedMatrix.grid, matrix.grid)
            
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

    final class LoadAudioTest: XCTestCase {
        func testResample() {

            let signal: Array<Float> = [
                1.27174494,  1.66345856,  1.08286779, -1.80101048,  2.33882082,
                -0.48808984,  1.57177628, -2.10783596,  0.15247092,  0.33422527,
                -0.20697387,  1.08023226, -1.12521487,  0.03200324, -0.35877198,
                -0.49989168,  0.39635374,  2.33790909, -0.34074211,  1.02720771,
                0.6516558 , -1.0792922 ,  0.33025431,  1.52766385, -2.54268464,
                -2.35512839, -0.88876004,  0.92088861,  0.93955161,  1.63318916,
                0.36169159, -0.4641148 ,  0.55130261,  2.22848876, -0.75330101,
                0.33265688,  0.29952085,  1.54613234, -0.11307855, -2.02219962,
                1.53925388, -0.84767996,  1.09673645,  0.13040098, -1.25405195,
                -1.01581605,  1.47991707,  0.21276737,  1.20421117,  0.54367296,
                0.49288088, -1.03651585, -1.35920492,  0.22900151, -1.70247823,
                -1.83977356, -0.40514344, -0.48519017,  0.24865654,  1.02352468,
                -1.72674487, -0.48069874,  0.07212921, -0.90324529,  1.06129275,
                -2.00976121, -0.55080446,  0.03019165, -0.42351282,  0.95571276,
                0.14258015,  0.98844825,  0.42841381,  1.45188302, -1.33808809,
                0.48965644, -1.84142222, -0.3790876 , -0.11787419,  1.04573222,
                -0.68878973,  1.51961732, -0.54513989,  0.10976337, -1.26123649,
                -0.33697389,  0.45061333,  0.53749695,  0.55599312, -0.30723908,
                -1.1456372 ,  1.35128031,  0.07806805, -0.96871128, -1.24319152,
                0.21844981,  1.19218494, -1.37550781,  0.74886571,  0.72432921
            ]
            
            let resampledSignalPython: Array<Float> = [
                1.0416998 ,  0.50106688,  0.44606776, -0.47113011,  0.3697199 ,
                -0.43493904,  0.04092213,  1.00536741,  0.23238114, -0.067116  ,
                -1.66871417,  0.72958164,  0.86292769,  0.20580085,  0.8681265 ,
                -0.18424964,  0.14334247, -0.06694768, -0.33712522,  0.97421514,
                0.09579414, -1.04159946, -1.1838804 , -0.03204117, -0.32521302,
                -0.43725969, -0.47794058, -0.40407955,  0.83781158,  0.50477124,
                -0.51708838, -0.5929258 ,  0.8123787 , -0.45564152, -0.16235634,
                0.30556545, -0.03931404, -0.24367752, -0.39240941,  0.39055715
            ]
            
            let srOrig: Float = Float(15)
            let srNew: Float = Float(6)
            
            let resampledSignal: Array<Float> = try! resample(
                signal: signal,
                sampleRateOrig: srOrig,
                sampleRateNew: srNew
            )
            
            let absError = zip(resampledSignal, resampledSignalPython).map {abs($0 - $1)}
            let tol: Float = 1e-2
            for err in absError {
                print(err)
                XCTAssertTrue(err < tol)
            }
        }
            
        func testSincWindow() {
            let tol: Float = 1e-6
            let windowPython: Array<Float> = [0.945     , 0.9449947 , 0.9449788 , 0.9449523 , 0.94491519,
                                              0.94486749, 0.94480919, 0.9447403 , 0.9446608 , 0.94457072,
                                              0.94447004, 0.94435877, 0.94423691, 0.94410447, 0.94396145,
                                              0.94380784]
            
            let (window, _) = sincWindow(window: nil)
            
            let absError = zip(window, windowPython).map {abs($0 - $1)}
            
            for err in absError {
                XCTAssertTrue(err < tol)
            }
        }
    }

    final class OsUtilsTest : XCTestCase {
        func testSaveCompressedData() {
            let array : [[Float]] = [[1.1, 3.7] , [2.5, 6.4], [7.8, 8.3]]
            let matrix: Matrix<Float> = Matrix(array: array)

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
    }

