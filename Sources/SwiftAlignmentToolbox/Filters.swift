//
//  Filters.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 17.10.21.
//

import Foundation
import Surge
import Accelerate
import Algorithms

public class Filterbank {
    public let filterbank: Matrix<Float>
    public let binFrequencies: Array<Float>
    public let numBins: Int
    public let numBands: Int
    public let fMin: Float
    public let fMax: Float
    
    public init(
        filterbank: Matrix<Float>,
        binFrequencies: Array<Float>
    ) {
            self.filterbank = filterbank
            self.binFrequencies = binFrequencies
            self.numBins = self.filterbank.rows
            self.numBands = self.filterbank.columns
            self.fMin = min(binFrequencies)
            self.fMax = max(binFrequencies)
        }
}

public class Filter {
    let start: Int
    // let stop: Int
    let data: Array<Float>
    let norm: Bool

    public init(data: Array<Float>, start: Int = 0 , norm: Bool = false) {
        self.norm = norm
        if self.norm {
            self.data = data / Surge.sum(data)
        } else {
            self.data = data
        }
        self.start = start
        // self.stop = self.start + data.count
    }
}

public class TriangularFilter: Filter {
    let center: Int
    let stop: Int
    public init(data: Array<Float>, start: Int, center: Int, stop: Int, norm: Bool = false) {
        self.center = center
        self.stop = stop
        super.init(
            data: data,
            start: start,
            norm: norm
        )
    }

    static public func new(start: Int, center: Int, stop: Int, norm: Bool) -> TriangularFilter{
        // TODO: assert start <= center < stop
        assert(start <= center && center < stop)
        
        let count: Int = stop - start
        let mid: Int = center - start
        var data: Array<Float> = Array(repeating: 0, count: count)
        let risingEdge = linSpace(start: 0, stop: 1, num: mid, endpoint: false)
        let fallingEdge = linSpace(start: 1, stop: 0, num: count - mid, endpoint: false)
        
        data.replaceSubrange(0..<mid, with: risingEdge)
        data.replaceSubrange(mid..<count, with: fallingEdge)
        
        let filter = TriangularFilter(
            data: data,
            start: start,
            center: center,
            stop: stop,
            norm: norm
        )
        return filter
    }
    
    
    
    
}
/*
public class MelFilterbank: Filterbank {
    
    public init(
        binFrequencies: Array<Float>,
        numBands: Int = 40,
        fMin: Float = 20,
        fMax: Float = 17000
    ) {
        let frequencies = melFrequencies(
            numBands: numBands + 2,
            fMin: fMin,
            fMax: fMax
        )
        
    }
}
*/
public func melFrequencies(numBands: Int, fMin: Float, fMax: Float) -> Array<Float> {
    let melFMin : Float = hz2Mel(fMin)
    let melFMax : Float = hz2Mel(fMax)
    let melFreqs = linSpace(start: melFMin, stop: melFMax, num: numBands)
    let hzMelFreqs = mel2Hz(melFreqs)
    return hzMelFreqs
}

public func hz2Mel(_ freqs: Array<Float>) -> Array<Float>{
    let melFreqs : Array<Float> = Surge.log((freqs / 700.0) + 1.0) * 1127.01048
    return melFreqs
}

public func hz2Mel(_ freq: Float) -> Float {
    let melFreq: Float = 1127.01048 * log(freq / 700.0 + 1.0)
    return melFreq
}

public func mel2Hz(_ melFreqs: Array<Float>) -> Array<Float> {
    let freq: Array<Float> = (Surge.exp(melFreqs / 1127.01048) - 1.0) * 700.0
    return freq
}


public func frequencies2Bins(frequencies: Array<Float>, binFrequencies: Array<Float>, uniqueBins: Bool = false) -> Array<Int> {
    // TODO: Current implementation does not have identical results to madmom's
    let indices: Array<Int> = interpolationSearch(binFrequencies, frequencies)
    
    if uniqueBins {
        let uniqueIndices: Array<Int> = Array(indices.uniqued())
        return uniqueIndices
    }
    return indices
}

