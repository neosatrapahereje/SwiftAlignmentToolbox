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
        
        // spectrogram.saveToFile(path: path)
        
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
        // let spectrogram: Matrix<Float> = linearSpectrogramAlignmentFeatures(url: SampleData.audioExampleMonoURL!)
        let kdfpath: String = "/Users/carlos/Documents/RITMO/MusicLab2020/ScoreFollowing/data/DSQ_tracks/kdf_c14_mono.wav"
        
        print("Computing spectrogram")
        let spectrogram: Matrix<Float> = linearSpectrogramAlignmentFeatures(
            path: kdfpath,
            frameSize: 2048,
            hopSize: Int(44100.0 * 0.01)
        )
        print(spectrogram.rows)
        print(spectrogram.columns)
        
        let path: String = "/Users/carlos/Repos/ContraPunctor/dsq_tracks-kdf_c14_mono.json"
        
        // spectrogram.saveToFile(path: path)
        
        print("Saving matrix")
        saveMatrix(matrix: spectrogram, path: path)
        print("Reloading Matrix")
        let reloadedMatrix: Matrix<Float> = readMatrixFromConfig(path: path)
        
        XCTAssertEqual(reloadedMatrix, spectrogram)
        // Remove temp file
    }
     */
}
