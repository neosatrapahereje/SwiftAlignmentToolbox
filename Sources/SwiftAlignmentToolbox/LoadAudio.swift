//
//  LoadAudio.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 16.09.21.
//

import Foundation
import AVFoundation

public func loadAudioFile(path: String, numChannels: Int?) -> Matrix<Float>? {
    do {
        let url = URL(fileURLWithPath: path)
        let file = try AVAudioFile(forReading: url)
        // let nChannels = Int(file.fileFormat.channelCount)
        if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                      sampleRate: file.fileFormat.sampleRate,
                                      channels: file.fileFormat.channelCount,
                                      interleaved: false), let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) {

            try file.read(into: buf)
            let frameLength = Int(buf.frameLength)
            // let nChannels = buf.floatChannelData.count

            // guard let floatChannelData = buf.floatChannelData else { print(2) }
            let floatChannelData = buf.floatChannelData
            
            var channelData: [[Float]] = []
            
            for i in Array(0..<frameLength) {
                channelData.append(
                    Array(
                        UnsafeBufferPointer(
                            start:floatChannelData![i],
                            count:frameLength
                        )
                    )
                )
            }
            
            let signal: Matrix<Float> = Matrix(array: channelData)
            return signal

        }
    } catch {
        print("Audio Error: \(error)")

    }
    return nil
}
