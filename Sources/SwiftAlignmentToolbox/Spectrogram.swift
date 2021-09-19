//
//  Spectrogram.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 17.09.21.
//

import Foundation
import Accelerate

func computeFFT(
    inputReal: Array<Float>,
    inputImaginary: Array<Float>,
    outputReal: inout Array<Float>,
    outputImaginary: inout Array<Float>,
    frameSize: Int
) {
    // Compute FFT
    let fwdDFT = vDSP.DFT(
        count: frameSize,
        direction: .forward,
        transformType: .complexComplex,
        ofType: Float.self)!
    fwdDFT.transform(
        inputReal: inputReal,
        inputImaginary: inputImaginary,
        outputReal: &outputReal,
        outputImaginary: &outputImaginary)
}

func computeMagnitudeSpectrogram(
    fftOutputReal: inout Array<Float>,
    fftOutputImaginary: inout Array<Float>,
    spectrogram: inout Array<Float>,
    frameSize: Int
) {
    // Compute Magnitude Spectrogram
    fftOutputReal.withUnsafeMutableBufferPointer {realBP in
                fftOutputImaginary.withUnsafeMutableBufferPointer {imaginaryBP in
                    var splitComplex = DSPSplitComplex(
                        realp: realBP.baseAddress!,
                        imagp: imaginaryBP.baseAddress!
                    )
                    vDSP_zvabs(&splitComplex, 1, &spectrogram, 1, vDSP_Length(frameSize))
                }
            }
}

public class SpectrogramProcessor {
    
    let frameSize: Int // TODO: Ensure that this is a power of two
    var outputReal: Array<Float>
    var outputImaginary: Array<Float>
    let inputImaginary: Array<Float> // We assume that the signals are all real
    var spectrogram: Array<Float>
    let numFFTBins: Int
    
    public init(
        frameSize: Int,
        includeNyquist: Bool = false
    ) {
        // TODO: Add checks so that frameSize is a power of 2
        self.frameSize = frameSize
        
        if includeNyquist {
            self.numFFTBins = (self.frameSize >> 1) + 1
        } else {
            self.numFFTBins = (self.frameSize >> 1)
        }
        self.outputReal = Array(repeating: Float(0), count: self.frameSize)
        self.outputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.inputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.spectrogram = Array(repeating: Float(0), count: self.frameSize)
    }
    
    public func process(frames: FramedSignal) -> Matrix<Float>{
        var spectrogram = Matrix(
            rows: frames.numFrames,
            columns: self.numFFTBins,
            defaultValue: Float(0)
        )
        for i in 0..<frames.numFrames {
            self.computeSpectrogram(frame: frames[i])
            for j in 0..<self.numFFTBins {
                spectrogram[i, j] = self.spectrogram[j]
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
    
    public func process(frame: Array<Float>) -> Array<Float> {
        self.computeSpectrogram(frame: frame)
        let spectrogram: Array<Float> = Array(self.spectrogram[0..<self.numFFTBins])
        return spectrogram
    }
    
    public func process(frame: Array<Float>, spectrogram: inout Array<Float>) {
        // Check that spectrogam has the same number of elements?
        // For speed reasons, probably not...
        self.computeSpectrogram(frame: frame)
        for i in 0..<self.numFFTBins {
            spectrogram[i] = self.spectrogram[i]
        }
    }
    public func computeSpectrogram(frame: Array<Float>) {
        // TODO: Add window and number of bins
        computeFFT(
            inputReal: frame,
            inputImaginary: self.inputImaginary,
            outputReal: &self.outputReal,
            outputImaginary: &self.outputImaginary,
            frameSize: self.frameSize
        )
        computeMagnitudeSpectrogram(
            fftOutputReal: &self.outputReal,
            fftOutputImaginary: &self.outputImaginary,
            spectrogram: &self.spectrogram,
            frameSize: self.frameSize
        )
    }
}


