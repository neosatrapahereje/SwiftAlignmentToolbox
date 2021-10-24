//
//  MathUtils.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 14.09.21.
//

import Foundation
import Accelerate
import Darwin
import Surge

/*
/** Array--related utils */
public func transpose<T>(_ input: [[T]]) -> [[T]] {
    // Transpose a 2D array
    if input.isEmpty { return [[T]]() }
    let count = input[0].count
    var out = [[T]](repeating: [T](), count: count)
    for outer in input {
        for (index, inner) in outer.enumerated() {
            out[index].append(inner)
        }
    }
    return out
}
*/

public func normalize(signal: Array<Float>) -> Array<Float> {
    // Normalize signal
    // let scaling: Float = signal.map{abs($0)}.max()!
    let scaling: Float = Float(1) / (Surge.max(Surge.abs(signal)) + 1e-10)
    let normalizedSignal: Array<Float> = Surge.mul(signal, scaling)
    return normalizedSignal
}

public func normalize(signal: Matrix<Float>) -> Matrix<Float> {
    let scaling: Float = Float(1) / (Surge.max(Surge.abs(signal)) + 1e-10)
    let normalizedSignal: Matrix<Float> = Surge.mul(scaling, signal)// scaling * signal
    return normalizedSignal
}

public func normalize(signal: Vector<Float>) -> Vector<Float> {
    let scaling: Float = Float(1) / (Surge.max(Surge.abs(signal.scalars)) + 1e-10)
    let normalizedSignal: Vector<Float> = Surge.mul(signal, scaling)
    return normalizedSignal
}

public func rescale(signal: Array<Float>) -> Array<Float>{
    // Rescale the signal to  range [-1, 1]
    let normalizedSignal: Array<Float> = signal.map{$0 / Float.greatestFiniteMagnitude}
    return normalizedSignal
}

public func sinc(_ x: Float) -> Float {
    // Sinc function
    let pix: Float = Float.pi * x
    let res: Float
    if pix == 0.0 {
        res = 1.0
    } else {
        res = sin(pix) / pix
    }
    return res
}

public func sinc(_ x: Array<Float>) -> Array<Float> {
    let res: Array<Float> = x.map {sinc($0)}
    return res
}


public func resampleArray(
    x: Array<Float>,
    y: inout Array<Float>,
    sampleRatio: Float,
    interpWindow: Array<Float>,
    interpDelta: Array<Float>,
    numTable: Int // The number of bits of precision to use in the filter table
) {
    // This is a port of resample_f in resampy
    
    let scale: Float = min(1.0, sampleRatio)
    let timeIncrement: Float = 1.0 / sampleRatio
    let indexStep: Int = Int(scale * Float(numTable))
    var timeRegister: Float = 0.0

    var n: Int = 0
    var frac: Float = 0.0
    var indexFrac: Float = 0.0
    var offset: Int = 0
    var eta: Float = 0.0
    var weight: Float = 0.0

    let nWin: Int = interpWindow.count
    let nOrig: Int = x.count
    let nOut: Int = y.count
    // let nChannels: Int = 1
    
    var iMax: Int
    var kMax: Int

    for t in 0..<nOut {
        // Grab the top bits as an index to the input buffer
        n = Int(timeRegister)

        // Grab the fractional component of the time index
        frac = scale * (timeRegister - Float(n))

        // Offset into the filter
        indexFrac = frac * Float(numTable)
        offset = Int(indexFrac)

        // Interpolation factor
        eta = indexFrac - Float(offset)

        // Compute the left wing of the filter response
        iMax = min(n + 1, (nWin - offset) / indexStep)
        for i in 0..<iMax {
            weight = (interpWindow[offset + i * indexStep] + eta * interpDelta[offset + i * indexStep])
            y[t] += weight * x[n - i]
            }

        // Invert P
        frac = scale - frac

        // Offset into the filter
        indexFrac = frac * Float(numTable)
        offset = Int(indexFrac)

        // Interpolation factor
        eta = indexFrac - Float(offset)

        // Compute the right wing of the filter response
        kMax = min(nOrig - n - 1, (nWin - offset) / indexStep)
            for k in 0..<kMax {
                weight = (interpWindow[offset + k * indexStep] + eta * interpDelta[offset + k * indexStep])
                y[t] += weight * x[n + k + 1]
            }
        // Increment the time register
        timeRegister += timeIncrement
    }
}

public func linSpace(start: Float, stop: Float, num: Int, endpoint: Bool = true) -> Array<Float>{
    let div: Int
    if endpoint {
        div = num - 1
    } else {
        div = num
    }
    // An (incomplete) port of numpy's linspace
    let delta: Float = stop - start
    let step: Float = delta / Float(div)
    let yRange: Range =  0..<num
    var y: Array<Float>
    
    if div > 0 {
        y = yRange.map {(Float($0) * step) + start}
    } else {
        y = yRange.map {(Float($0) * delta) + start}
    }
    
    if endpoint && num > 1 {
        y[num - 1] = stop
    }
    return y
}
/*** Local Distances    */
public func l1Distance(_ x: [Float], _ y: [Float]) -> Float {
    // L1 (Manhattan) Distance between two vectors
    /*
    var dist: Float = 0
    for (i, val) in x.enumerated(){
        dist += abs(y[i] - val)
    }
     */
    let dist: Float = Surge.sum(Surge.abs(Surge.sub(x, y)))
    return dist
}

public func CosineDistance(_ x: [Float], _ y: [Float]) -> Float {
    // Cosine Distance between two vectors
    var dist: Float = 0
    var dot: Float = 0
    var normX: Float = 0
    var normY: Float = 0
    var cos: Float = 0
    
    dot = vDSP.dot(x, y)
    normX = vNorm(x)
    normY = vNorm(y)
    
    cos = dot / (normX * normY + 1e-10)
    
    dist = 1 - cos
    return dist
}

public func EuclideanDistance(_ x: [Float], _ y: [Float]) -> Float {
    // Euclidean Distance
    // var dist: Float = 0
    // let dist: Float = sqrt(vDSP.distanceSquared(x, y))
    let dist: Float = Surge.dist(x, y)
    return dist
}

/** Other utilities */
public func vNorm(_ x: [Float]) -> Float {
    // Norm of a vector
    // Probably this method exists somewhere else...
    let norm = sqrt(vDSP.dot(x, x))
    return norm
}


public func interpolationSearch(_ array: Array<Float>, _ key: Float) -> Int
{
    // Adapted from https://en.wikipedia.org/wiki/Interpolation_search
    // This method assumes that `array` is sorted
    var low: Int = 0;
    var high: Int = array.count - 1
    // var mid: Int
    // let fKey = Float(key)
    var pos: Int = array.count - 1

    if (key <= array[low]) {
        return low
    }

    while ((array[high] != array[low]) && (key >= array[low]) && (key <= array[high]))
    {
        pos = Int(Float(low) + ((key - array[low]) * Float(high - low) / (array[high] - array[low])))
        print(pos)

        if (array[pos] < key) {
            low = pos + 1
        }
        else if (key < array[pos]) {
            high = pos - 1
        }
        else {
            return pos
        }
    }

    return pos
}

public func interpolationSearch(_ array: Array<Float>, _ keys: Array<Float>) -> Array<Int>
{
    var indices: Array<Int> = Array(repeating: 0, count: keys.count)
    
    for (i, key) in keys.enumerated() {
        indices[i] = interpolationSearch(array, key)
    }
    return indices
}

public class LinearInterpolation {
    // Adapted from https://stackoverflow.com/a/53213532
    private var n : Int
    private var x : [Float]
    private var y : [Float]
    public init (x: [Float], y: [Float], assumeSorted: Bool = false) {
        assert(x.count == y.count)
         
        self.n = x.count-1
        
        if assumeSorted{
            // Assumes elements are sorted
            self.x = x
            self.y = y
        } else {
            let uniqueX: [Float] = Array<Float>(x.uniqued())
            let sortIdxs = argsort(uniqueX)
            self.x = uniqueX.sorted()
            self.y = [Float](repeating: 0, count: self.x.count)
            for (i, ui) in sortIdxs.enumerated() {
                self.y[i] = y[ui]
            }
        }
    }
    
    public func callAsFunction(_ t: Float) -> Float {
        if t <= x[0] { return y[0] }
        for i in 1...n {
            if t <= x[i] {
                let ans = (t-x[i-1]) * (y[i] - y[i-1]) / (x[i]-x[i-1]) + y[i-1]
                return ans
            }
        }
        return y[n]
    }
    public func callAsFunction(_ t: [Float]) -> [Float] {
        let result: [Float] = t.map { self($0) }
        return result
    }
}

public func argsort<T>(_ l:[T]) -> [Int] where T: Comparable {
    // Adapted from https://codegolf.stackexchange.com/a/136655
    var sortIndices = [Int](repeating: 0, count: l.count)
    for (i, k) in (l.sorted()).enumerated(){
        sortIndices[i] = l.firstIndex(of: k)!
    }
    return sortIndices
}
