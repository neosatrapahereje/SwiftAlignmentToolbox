//
//  Processor.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 19.10.21.
//

import Foundation

public class Processor {
    
    public func callAsFunction(frame: Array<Float>) -> Array<Float> {
        // Use processor as callable
        return self.process(frame: frame)
    }

    public func process(frame: Array<Float>) -> Array<Float> {
        // identity function
        return frame
    }
}
