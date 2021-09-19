//
//  LoadAudio.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 16.09.21.
//

import Foundation
import AVFoundation
import Accelerate

public enum LoadAudioError: Error {
    case RemixError
    case SampleRateError
    case ResampleError
}

public func loadAudioFile(path: String, numChannels: Int?, sampleRate: Float?) -> Matrix<Float> {
    let url = URL(fileURLWithPath: path)

    let audio =  try! AVAudioFile(forReading : url)
    
    var doResample: Bool = false
        
    if sampleRate != nil {
        if Float(audio.fileFormat.sampleRate) != sampleRate! {
            doResample = true
        }
    }

    let format = AVAudioFormat(commonFormat:.pcmFormatFloat32, sampleRate:audio.fileFormat.sampleRate, channels: audio.fileFormat.channelCount,  interleaved: false)
    let audioBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(audio.length))!
    try! audio.read(into : audioBuffer, frameCount:UInt32(audio.length))
    let arraySize = Int(audioBuffer.frameLength)

    var samples: [[Float]] = []
    
    for channel in 0..<audio.fileFormat.channelCount {
        
        let channelData: Array<Float> = Array(
            UnsafeBufferPointer(
                start: audioBuffer.floatChannelData![Int(channel)], count:arraySize
            )
        )
        
        if doResample {
            
            let resampledChannelData: Array<Float> = try! resample(
                signal: channelData,
                sampleRateOrig: Float(audio.fileFormat.sampleRate),
                sampleRateNew: sampleRate!
            )
            samples.append(resampledChannelData)
        } else {
            samples.append(channelData)
        }
        
    }
    
    // Rows are samples, channels are columns
    let signal = Matrix<Float>(array: transpose(samples))
    
    if numChannels != nil {
        let remixedSignal = try! remix(signal: signal, numChannels: numChannels!)
        return remixedSignal
    } else {
        return signal
    }
}

public func remix(signal: Matrix<Float>, numChannels: Int) throws -> Matrix<Float> {
    var remixedSignal: Matrix<Float> = Matrix(
        rows: signal.rows,
        columns: numChannels,
        defaultValue: Float(0)
    )
    
    let cond1: Bool = signal.columns == 1 && numChannels >= 1
    let cond2: Bool = signal.columns > 1 && numChannels == 1
    
    guard cond1 || cond2 else {
        throw LoadAudioError.RemixError
    }
    
    if  cond1 {
        for row in 0..<signal.rows {
            for col in 0..<numChannels {
                remixedSignal[row, col] = signal[row, 0]
            }
            
        }
    } else if cond2 {
        for row in 0..<signal.rows {
            vDSP_meanv(signal[row, 0..<signal.columns], 1, &remixedSignal[row, 0], vDSP_Length(signal.columns))
        }
    }
    return remixedSignal
}

/** **Port of resampy**
 # TODO
 * Add options for filters (or use the precomputed filters in the Python package)?
 */
public func resample(
    signal: Array<Float>,
    sampleRateOrig: Float,
    sampleRateNew: Float
    // filter: String = "kaiser_best" // TODO: Add filters
) throws -> Array<Float> {

    guard sampleRateOrig > 0 else {
        throw LoadAudioError.SampleRateError
    }
    
    guard sampleRateNew > 0 else {
        throw LoadAudioError.SampleRateError
    }
    
    let sampleRatio: Float = sampleRateNew / sampleRateOrig
    
    let newCount: Int = Int(Float(signal.count) * sampleRatio)
    
    guard newCount > 1 else {
        throw LoadAudioError.ResampleError
    }
    
    var resampledSignal: Array<Float> = Array(repeating: Float(0), count: newCount)
    
    let (interpWindow, precision) = sincWindow(
        numZeros: 64,
        precision: 9,
        rollOff: 0.945,
        window: nil)

    var interpDelta : Array<Float> = Array(repeating: Float(0), count: interpWindow.count)
    
    for i in 1..<interpWindow.count {
        interpDelta[i - 1] = interpWindow[i] - interpWindow[i - 1]
    }
    resampleArray(
        x: signal,
        y: &resampledSignal,
        sampleRatio: sampleRatio,
        interpWindow: interpWindow,
        interpDelta: interpDelta,
        numTable: precision
    )
    return resampledSignal
}

public func sincWindow(
    numZeros: Int = 64,
    precision: Int = 9,
    rollOff: Float = 0.945,
    window: ((Int) -> Array<Float>)? = nil
) -> (Array<Float>, Int){

    
    let numBits: Int = Int(Darwin.pow(Double(2), Double(9)))
    
    let n: Int = numBits * numZeros
    
    var interpWindow: Array<Float> = Array(repeating: Float(0), count: n + 1)
    
    let sincWindow: Array<Float> = sinc(
        linSpace(
            start:Float(0),
            stop:Float(numZeros),
            num: n + 1,
            endpoint: true
        ).map { $0 * rollOff}
    ).map { $0 * rollOff}
    
    var taper: Array<Float> = Array(repeating: Float(0), count: 2 * n + 1)
    if window != nil {
        taper = window!(2 * n + 1)
        // let taper: Array<Float> = Array(windw[n:])
    } else {
        vDSP_blkman_window(&taper, vDSP_Length(2 * n + 1), 0)
    }
    
    vDSP_vmul(sincWindow, 1, Array(taper[n..<2 * n + 1]), 1, &interpWindow, 1, vDSP_Length(n + 1))
    
    return (interpWindow, numBits)
}
