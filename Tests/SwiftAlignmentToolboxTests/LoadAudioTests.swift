//
//  LoadAudioTests.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 02.10.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge


final class LoadAudioTest: XCTestCase {
    
    func testLoadAudioFile() {
        let (audioFileStereo, sampleRate) = loadAudioFile(url: SampleData.audioExampleStereoURL!)
        XCTAssertEqual(sampleRate, Double(44100))
        XCTAssertEqual(Double(audioFileStereo.rows) / sampleRate, Double(2))
        XCTAssertEqual(audioFileStereo.columns, 2)
    }
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
