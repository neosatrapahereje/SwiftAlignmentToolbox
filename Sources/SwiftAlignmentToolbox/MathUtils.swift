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
    // var norm : Float = 0
    let norm = sqrt(vDSP.dot(x, x))
    return norm
}


