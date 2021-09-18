//
//  Spectrogram.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 17.09.21.
//

import Foundation
import Accelerate

public func fft_online(
    realInput: inout Array<Float>,
    imaginaryInput: inout Array<Float>,
    realOutput: inout Array<Float>,
    imaginaryOutput: inout Array<Float>,
    frameSize: Int
) {
    // Compute FFT
    let fwdDFT = vDSP.DFT(
        count: frameSize,
        direction: .forward,
        transformType: .complexComplex,
        ofType: Float.self)!
    fwdDFT.transform(
        inputReal: realInput,
        inputImaginary: imaginaryInput,
        outputReal: &realOutput,
        outputImaginary: &imaginaryOutput)
}

public func spectrogram_online(
    fftOutputReal: inout Array<Float>,
    fftOutputImaginary: inout Array<Float>,
    spectrogram: inout Array<Float>,
    frameSize: Int
) {
    // Compute Magnitude Spectrogram
    fftOutputReal.withUnsafeMutableBufferPointer {realBP in
                fftOutputImaginary.withUnsafeMutableBufferPointer {imaginaryBP in
                    var splitComplex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imaginaryBP.baseAddress!)
                    vDSP_zvabs(&splitComplex, 1, &spectrogram, 1, vDSP_Length(frameSize))
                }
            }
}

public class Spectrogram {
    
    let frameSize: Int
    var outputReal: Array<Float>
    var outputImaginary: Array<Float>
    
    public init(
        frameSize: Int
    ) {
        self.frameSize = frameSize
        
        
    }
    
    

}
