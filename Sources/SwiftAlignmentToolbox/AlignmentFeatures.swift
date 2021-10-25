//
//  AlignmentFeatures.swift
//  Pipelines to compute audio features for alignment.
//
//  Created by Carlos Eduardo Cancino-Chacón on 23.09.21.
//

import Foundation
import Surge

func linearSpectrogramAlignmentFeatures(
    signal: Signal,
    frameSize: Int = FRAME_SIZE,
    hopSize: Int = HOP_SIZE,
    window: String = "hanning",
    includeNyquist: Bool = false
) -> Matrix<Float> {
    let framedSignal = FramedSignal(
        signal: signal,
        frameSize: frameSize,
        hopSize: hopSize)
    let spectrogram = Spectrogram(framedSignal: framedSignal,
                                  includeNyquist: includeNyquist,
                                  window: window)
    return spectrogram.spectrogram
}

func linearSpectrogramAlignmentFeatures(
    url: URL,
    frameSize: Int = FRAME_SIZE,
    hopSize: Int = HOP_SIZE,
    window: String = "hanning",
    includeNyquist: Bool = false
) -> Matrix<Float>  {
    let audio: Matrix<Float>
    let sampleRate: Double
    (audio, sampleRate) = loadAudioFile(url: url)
    print("Sample Rate \(sampleRate)")
    let signal = Signal(
        data: audio,
        sampleRate: Int(sampleRate)
    )
    let spectrogram = linearSpectrogramAlignmentFeatures(
        signal: signal,
        frameSize: frameSize,
        hopSize: hopSize,
        window: window,
        includeNyquist: includeNyquist
    )
    return spectrogram
}

func linearSpectrogramAlignmentFeatures(
    path: String,
    frameSize: Int = FRAME_SIZE,
    hopSize: Int = HOP_SIZE
) -> Matrix<Float>  {
    let url: URL = URL(fileURLWithPath: path)
    let spectrogram = linearSpectrogramAlignmentFeatures(
        url: url,
        frameSize: frameSize,
        hopSize: hopSize
    )
    return spectrogram
}
