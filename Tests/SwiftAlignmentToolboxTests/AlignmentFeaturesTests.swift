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

final class AlignmentFeaturesTest: XCTestCase {
    func testLinearSpectrogramAlignmentFeatures() {
        let spectrogram: Matrix<Float> = linearSpectrogramAlignmentFeatures(url: SampleData.audioExampleMonoURL!)
        print(spectrogram.rows)
        print(spectrogram.columns)
        
        let path: String = "/tmp/swift_testFeatureSaving.swz"
            
        saveMatrix(matrix: spectrogram, path: path)
        
        let reloadedMatrix: Matrix<Float> = readMatrixFromConfig(path: path)
        
        XCTAssertEqual(reloadedMatrix, spectrogram)
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
    
    /*
    func testLinearSpectrogramAlignmentKDF14() {
        
        let samplingRate = 44100
        let version: String = "ver3"
        let kdfpath: String = "/Users/carlos/Documents/RITMO/MusicLab2020/ScoreFollowing/data/dsq_rehearsal_2021-10-21/kdf_c14_dsq_\(version)_mono_\(samplingRate).wav"
        
        let frameSize = 4096
        let hopSize = Int(Float(samplingRate) * 0.05)
        print("Computing spectrogram")
        let spectrogram: Matrix<Float> = linearSpectrogramAlignmentFeatures(
            path: kdfpath,
            frameSize: frameSize,
            hopSize: hopSize
        )
        print(spectrogram.rows)
        print(spectrogram.columns)
        
        let path: String = "/Users/carlos/Downloads/ContraPunctor/kdf_c14_dsq_\(version)_linearSpectrogram_hsz_\(hopSize)_fsz_\(frameSize)_sr_\(samplingRate).json"
        
        print("Saving matrix")
        saveMatrix(matrix: spectrogram, path: path)
        print("Reloading Matrix")
        let reloadedMatrix: Matrix<Float> = readMatrixFromConfig(path: path)
        
        XCTAssertEqual(reloadedMatrix, spectrogram)
    }
     */

}
