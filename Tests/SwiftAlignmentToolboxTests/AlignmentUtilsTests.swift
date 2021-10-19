//
//  AlignmentUtilsTest.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 19.10.21.
//

import Foundation
import XCTest
@testable import SwiftAlignmentToolbox
import Surge

final class AlignmentUtilsTests: XCTestCase {
    func testOnsetTracker() {
        let onsets: [Float] = [0, 2, 1, 4, 3]
        // XCTAssertEqual(a[4], Float(4))
        var onsetTracker = OnsetTracker(uniqueOnsets: onsets)
        
        let perfOnsets = linSpace(start: -0.1, stop: 4.1, num: 100)
        
        var so: Float?
        for po in perfOnsets {
            so = onsetTracker(po)
            // print(onsetTracker.performedOnsets, onsetTracker.currentOnset)
            if so != nil{
                XCTAssertEqual(round(so!), round(po))
            }
        }
        
    }
}

