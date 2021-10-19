import Foundation
import Surge

public enum SampleData {
    static public let audioExampleStereoURL = Bundle.module.url(forResource: "audio_example_stereo", withExtension: "wav")
    static public let audioExampleMonoURL = Bundle.module.url(forResource: "audio_example_mono", withExtension: "wav")
    static public let numpySignalExample = Bundle.module.url(forResource: "signal", withExtension: "txt")
    static public let numpyFramedSignalExample = Bundle.module.url(forResource: "framed_signal", withExtension: "txt")
    static public let numpySpectrogramExample = Bundle.module.url(forResource: "spectrogram", withExtension: "txt")
    static public let pythonWarpingPathExample = Bundle.module.url(forResource: "oltw_path", withExtension: "txt")
}

public struct OnlineAlignment {
    
    public let follower: OnlineTimeWarping
    public let processor: Processor
    public var currentPosition: Int
    public var currentTime: Float? = nil
    // a function that maps the indices in the reference to
    // time in the reference
    public let refTimeMap: ((Int) -> Float)?
    
    public init(
        follower: OnlineTimeWarping,
        processor: Processor,
        refTimeMap: ((Int) -> Float)? = nil
    )
    {
        self.follower = follower
        self.processor = processor
        self.currentPosition = self.follower.currentPosition
        self.refTimeMap = refTimeMap
    }
    
    public mutating func step(frame: [Float]) {
        let inputFeatures: [Float] = self.processor.process(frame: frame)
        self.follower.step(inputFeatures: inputFeatures)
        self.currentPosition = self.follower.currentPosition
    }
    
    public mutating func reset(currentPosition: Int) {
        self.follower.currentPosition = currentPosition
        self.currentPosition = currentPosition
        // TODO: Reset cost matrix?
    }
}
