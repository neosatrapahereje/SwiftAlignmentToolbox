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
}

public func loadAudioFile(path: String, numChannels: Int?) -> Matrix<Float> {
    let url = URL(fileURLWithPath: path)

    let audio =  try! AVAudioFile(forReading : url)

    let format = AVAudioFormat(commonFormat:.pcmFormatFloat32, sampleRate:audio.fileFormat.sampleRate, channels: audio.fileFormat.channelCount,  interleaved: false)
    let audioBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(audio.length))!
    try! audio.read(into : audioBuffer, frameCount:UInt32(audio.length))
    let arraySize = Int(audioBuffer.frameLength)

    var samples: [[Float]] = []
    
    for channel in 0..<audio.fileFormat.channelCount {
        samples.append(
            Array(
                UnsafeBufferPointer(
                    start: audioBuffer.floatChannelData![Int(channel)], count:arraySize
                )
            )
        )
    }
    
    let signal = Matrix<Float>(array: transpose(samples))
    
    if numChannels != nil {
        let remixedSignal = try! remix(signal: signal, numChannels: numChannels!)
        return remixedSignal
    }
    return signal
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
