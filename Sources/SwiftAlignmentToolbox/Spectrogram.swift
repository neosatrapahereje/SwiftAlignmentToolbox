//
//  Spectrogram.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 17.09.21.
//

import Foundation
import Accelerate

public func fft_online(
    realInput: Array<Float>,
    imaginaryInput: Array<Float>,
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
    let inputImaginary: Array<Float> // We assume that the signals are all real
    var spectrogram: Array<Float>
    
    public init(
        frameSize: Int
    ) {
        // TODO: Add checks so that frameSize is a power of 2
        self.frameSize = frameSize
        self.outputReal = Array(repeating: Float(0), count: self.frameSize)
        self.outputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.inputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.spectrogram = Array(repeating: Float(0), count: self.frameSize)
    }
    
    public func process(frames: FramedSignal) -> Matrix<Float>{
        var spectrogram = Matrix(
            rows: frames.numFrames,
            columns: self.frameSize,
            defaultValue: Float(0)
        )
        
        for i in 0..<frames.numFrames {
            self.computeSpectrum(frame: frames[i])
            for (j, val) in self.spectrogram.enumerated() {
                spectrogram[i, j] = val
            }
        }
        
        return spectrogram
    }
    
    public func process(
        signal: Signal,
        hopSize: Int = HOP_SIZE,
        origin: String = "center"
        ) -> Matrix<Float> {
        
        let frames = FramedSignal(
            signal: signal,
            frameSize: self.frameSize,
            hopSize: hopSize,
            origin: origin
        )
        let spectrogram = self.process(frames: frames)
        return spectrogram
    }
    
    public func computeSpectrum(frame: Array<Float>) {
        // TODO: Add window and number of bins
        fft_online(
            realInput: frame,
            imaginaryInput: self.inputImaginary,
            realOutput: &self.outputReal,
            imaginaryOutput: &self.outputImaginary,
            frameSize: self.frameSize
        )
        spectrogram_online(
            fftOutputReal: &self.outputReal,
            fftOutputImaginary: &self.outputImaginary,
            spectrogram: &self.spectrogram,
            frameSize: self.frameSize
        )
    }
}


