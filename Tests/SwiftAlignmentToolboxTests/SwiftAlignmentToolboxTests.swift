    import XCTest
    @testable import SwiftAlignmentToolbox
    import Surge
    
    final class AlignmentToolsTest: XCTestCase {
        func testOnlineTimeWarping() {
            
            let spectrogramURL = SampleData.numpySpectrogramExample!
            let referenceFeatures: Matrix<Float> = csvToMatrix(url: spectrogramURL)!
                
            let warpingPathURL = SampleData.pythonWarpingPathExample!
            let pwp: Matrix<Float> = csvToMatrix(url: warpingPathURL)!
            
            var pythonWarpingPath : [[Int]] = []
            
            for row in 0..<pwp.rows {
                let IntRow: [Int] = pwp[row: row].compactMap {Int($0)}
                pythonWarpingPath.append(IntRow)
                
            }
            let oltw = OnlineTimeWarping(
                referenceFeatures: referenceFeatures,
                stepSize: 5,
                windowSize: 10,
                localDistance: "L1"
            )
            
            var warpingPath: [[Int]] = []
            for i in 0..<referenceFeatures.rows {
                oltw(inputFeatures: referenceFeatures[row: i])
                warpingPath.append([i, oltw.currentPosition])
            }
            XCTAssertEqual(pythonWarpingPath, warpingPath)
        }
        
        /*
        func testOnlineTimeWarping2() {
            let refPath: String = "/Users/carlos/Downloads/dsq_tracks-kdf_c14_mono.json"
            
            let referenceFeatures: Matrix<Float> = readMatrixFromConfig(path: refPath)
            print(referenceFeatures.rows)

            let oltw = OnlineTimeWarping(
                referenceFeatures: referenceFeatures,
                stepSize: 5,
                windowSize: 100,
                localDistance: "L1"
            )
            
            for i in 0..<referenceFeatures.rows {
                oltw.step(inputFeatures: referenceFeatures[row: i])
            }
            // print(oltw.warpingPath)
        }
         */
         
    }
