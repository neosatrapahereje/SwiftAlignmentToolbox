//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 23.09.21.
//

import Foundation
import Surge

func linearSpectrogramAlignmentFeatures(path: String) -> Matrix<Float>  {
    
    let audio: Matrix<Float>
    let sampleRate: Double
    (audio, sampleRate) = loadAudioFile(path: path)


    /*
    let remixedAudio = Surge.mean(audio, axies: .row)
    print(remixedAudio.count)

    print(remixedAudio.columns)

    let resampledAudio = try! resample(signal: remixedAudio.grid,
                                      sampleRateOrig: Float(sampleRate),
                                      sampleRateNew: Float(sampleRate) / Float(16))
    print(resampledAudio.count)
     */

    let signal = Signal(
        data: audio,
        sampleRate: Int(sampleRate)
    )

    let framedSignal = FramedSignal(
        signal: signal)
    let spectrogram = Spectrogram(framedSignal: framedSignal)
    return spectrogram.spectrogram
}
