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
        // let (audioFileMono, sampleRate) = loadAudioFile(url: SampleData.audioExampleMonoURL!)
        let spectrogram: Matrix<Float> = linearSpectrogramAlignmentFeatures(url: SampleData.audioExampleMonoURL!)
        print(spectrogram.rows)
        print(spectrogram.columns)
        
        let path: String = "/tmp/swift_testFeatureSaving.swz"
        
        spectrogram.saveToFile(path: path)
        
        let reloadedMatrix: Matrix<Float> = readMatrixFromFile(path: path)
        
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
}
