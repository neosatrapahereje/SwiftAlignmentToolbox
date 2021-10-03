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
        
    }
}
