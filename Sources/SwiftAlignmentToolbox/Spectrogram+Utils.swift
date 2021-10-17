//
//  Spectrogram.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 17.09.21.
//

import Foundation
import Accelerate
import Surge

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

public class Processor {

    public func process(frame: Array<Float>) -> Array<Float> {
        // identity function
        return frame
    }
}

public class SpectrogramProcessor: Processor {
    
    // Useful info about the spectrogram
    public let frameSize: Int // TODO: Ensure that this is a power of two
    public let numFFTBins: Int
    public let fftFreqBins: Array<Float>
    public let sampleRate: Float
    
    // Convenience properties
    let fwdDFT: vDSP.DFT<Float>
    let window: Array<Float>
    var windowedFrame: Array<Float>
    let mulStride: Int = vDSP_Stride(1)
    let frameSizevDSP: vDSP_Length
    
    // Convenience initializations to allocate memory for computations
    var outputReal: Array<Float>
    var outputImaginary: Array<Float>
    let inputImaginary: Array<Float> // We assume that the signals are all real
    
    public init(
        frameSize: Int,
        includeNyquist: Bool = false,
        window: String = "hanning",
        sampleRate: Float = 1
    ) {
        // TODO: Add checks so that frameSize is a power of 2
        self.frameSize = frameSize
        self.sampleRate = sampleRate
        
        if includeNyquist {
            self.numFFTBins = (self.frameSize >> 1) + 1
        } else {
            self.numFFTBins = (self.frameSize >> 1)
        }
        self.outputReal = Array(repeating: Float(0), count: self.frameSize)
        self.outputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.inputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.fwdDFT = vDSP.DFT(
            count: self.frameSize,
            direction: .forward,
            transformType: .complexComplex,
            ofType: Float.self)!
        
        self.window = setupWindow(windowType: window, count: self.frameSize)
        self.windowedFrame = Array<Float>(repeating: Float(0), count: self.frameSize)
        // For multiplying frames and windows
        self.frameSizevDSP = vDSP_Length(self.frameSize)
        self.fftFreqBins = spectrogramFreqBins(numFFTBins: self.numFFTBins, sampleRate: self.sampleRate)
    }
    
    public init(
        framedSignal: FramedSignal,
        includeNyquist: Bool = false,
        window: String = "hanning"
    ) {
        self.frameSize = framedSignal.frameSize
        self.sampleRate = Float(framedSignal.signal.sampleRate)
        
        if includeNyquist {
            self.numFFTBins = (self.frameSize >> 1) + 1
        } else {
            self.numFFTBins = (self.frameSize >> 1)
        }
        self.fftFreqBins = spectrogramFreqBins(numFFTBins: self.numFFTBins, sampleRate: self.sampleRate)
        self.outputReal = Array(repeating: Float(0), count: self.frameSize)
        self.outputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.inputImaginary = Array(repeating: Float(0), count: self.frameSize)
        self.fwdDFT = vDSP.DFT(
            count: self.frameSize,
            direction: .forward,
            transformType: .complexComplex,
            ofType: Float.self)!
        
        self.window = setupWindow(windowType: window, count: self.frameSize)
        self.windowedFrame = Array<Float>(repeating: Float(0), count: self.frameSize)
        // For multiplying frames and windows
        self.frameSizevDSP = vDSP_Length(self.frameSize)
        // self.spectrogram = Array(repeating: Float(0), count: self.frameSize)
    }
    
    public func process(frames: FramedSignal) -> Matrix<Float>{
        
        var spectrogram = Matrix(
            rows: frames.numFrames,
            columns: self.numFFTBins,
            repeatedValue: Float(0)
        )
        for i in 0..<frames.numFrames {
            let spec = self.process(frame: frames[i])
            for j in 0..<self.numFFTBins {
                spectrogram[i, j] = spec[j]
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
        
    public override func process(frame: Array<Float>) -> Array<Float> {
        // Check that spectrogam has the same number of elements?
        // For speed reasons, probably not...
        var spectrogram: Array<Float> = Array(
            repeating: Float(0),
            count: self.numFFTBins)
        
        // Multiply by frame and window
        vDSP_vmul(frame, self.mulStride,
                  self.window, self.mulStride,
                  &self.windowedFrame, self.mulStride,
                  self.frameSizevDSP
        )
        self.computeSpectrogram(frame: self.windowedFrame, spectrogram: &spectrogram)
        return spectrogram
    }
    func computeSpectrogram(
        frame: Array<Float>,
        spectrogram: inout Array<Float>
    ){
        self.fwdDFT.transform(
            inputReal: frame,
            inputImaginary: self.inputImaginary,
            outputReal: &self.outputReal,
            outputImaginary: &self.outputImaginary)
        computeMagnitudeSpectrogram(
            fftOutputReal: &self.outputReal,
            fftOutputImaginary: &self.outputImaginary,
            spectrogram: &spectrogram,
            frameSize: self.numFFTBins
        )
    }
}

public struct Spectrogram {
    public let frameSize: Int // TODO: Ensure that this is a power of two
    public var spectrogram: Matrix<Float>
    public let numFFTBins: Int
    public let frames: FramedSignal
    let processor: SpectrogramProcessor
    
    public init(framedSignal: FramedSignal, includeNyquist: Bool = false, window: String = "hanning") {
        self.frames = framedSignal
        self.processor = SpectrogramProcessor(framedSignal: self.frames,
                                              includeNyquist: includeNyquist,
                                              window: window)
        self.frameSize = self.frames.frameSize
        self.numFFTBins = self.processor.numFFTBins
        self.spectrogram = self.processor.process(frames: self.frames)
    }
}

public func numpyWindow<T>(count: Int, sequence: vDSP.WindowSequence = .hanningDenormalized) -> [T] where T: vDSP_FloatingPointGeneratable  {
    // Hanning Window with the same results as numpy's window functions
    var window = vDSP.window(ofType:T.self,
                             usingSequence: sequence,
                             count: count - 1,
                             isHalfWindow: false)
    window.append(window[0])
    return window
}

public func numpyHanningWindow<T>(count: Int) -> [T] where T: vDSP_FloatingPointGeneratable  {
    let window: [T] = numpyWindow(count: count,
                                  sequence: vDSP.WindowSequence.hanningDenormalized)
    return window
}

public func numpyHammingWindow<T>(count: Int) -> [T] where T: vDSP_FloatingPointGeneratable  {
    let window: [T] = numpyWindow(count: count,
                                  sequence: vDSP.WindowSequence.hamming)
    return window
}

public func numpyBlackmanWindow<T>(count: Int) -> [T] where T: vDSP_FloatingPointGeneratable  {
    let window: [T] = numpyWindow(count: count,
                                  sequence: vDSP.WindowSequence.blackman)
    return window
}

func setupWindow(windowType: String, count: Int) -> Array<Float> {
    let window: Array<Float>
    
    switch windowType {
    case "hanning":
        window = vDSP.window(ofType:Float.self,
                             usingSequence: .hanningDenormalized,
                             count: count,
                             isHalfWindow: false)
    case "hanningPy":
        window = numpyHanningWindow(count: count)
    case "hamming":
        window = vDSP.window(ofType:Float.self,
                             usingSequence: .hamming,
                             count: count,
                             isHalfWindow: false)
    case "hammingPy":
        window = numpyHammingWindow(count: count)
    case "blackman":
        window = vDSP.window(ofType:Float.self,
                             usingSequence: .blackman,
                             count: count,
                             isHalfWindow: false)
    case "blackmanPy":
        window = numpyBlackmanWindow(count: count)
    default:
        window = vDSP.window(ofType:Float.self,
                             usingSequence: .hanningDenormalized,
                             count: count,
                             isHalfWindow: false)
    }
    return window
}

public func fftFrequencies(windowLength: Int, sampleRate: Float=1.0) -> Array<Float> {
    // Frequences of the FFT bins (of the output of an FFT)
    var fftFreqs: Array<Float> = Array(repeating: Float(0), count: windowLength)
    // sample spacing (inverse of sampling rate)
    let d : Float = 1.0 / sampleRate
    let val = 1.0 / (Float(windowLength) * d)
    let N = ((windowLength - 1) / 2) + 1
    
    for i in 0..<N {
        fftFreqs[i] = Float(i) * val
    }
    for i in 0..<windowLength - N {
        fftFreqs[i + N] = Float(-(windowLength/2) + i) * val
    }
    return fftFreqs
}

public func spectrogramFreqBins(numFFTBins: Int, sampleRate: Float) -> Array<Float> {
    // Frequencie bins of a linear magnitude spectrogram
    let fftFreqs: Array<Float> = fftFrequencies(windowLength: numFFTBins * 2, sampleRate: sampleRate)
    return Array(fftFreqs[0..<numFFTBins])
}
