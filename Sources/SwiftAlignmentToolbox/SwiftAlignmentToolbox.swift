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
    
    // Online Alignment Method
    public let follower: OnlineTimeWarping
    // Processor for preprocessing the features
    public let processor: Processor
    // the current index in the reference
    public var currentPosition: Int {
        get {
            return self.follower.currentPosition
        }
        set {
            self.follower.currentPosition = newValue
        }
    }
    // the current time in reference units (e.g., seconds)
    public var currentTime: Float? {
        get {
            if self.refTimeMap != nil {
                return self.refTimeMap!(self.currentPosition)
            } else {
                return nil
            }
        }
        set {
            if self.invRefTimeMap != nil {
                self.currentPosition = self.invRefTimeMap!(newValue!)
            }
        }
    }
    // a function that maps the indices in the reference to
    // time in the reference
    public let refTimeMap: ((Int) -> Float)?
    // a function that maps the time in the reference to the
    // index in the reference
    public let invRefTimeMap: ((Float) -> Int)?
    
    public init(
        follower: OnlineTimeWarping,
        processor: Processor,
        refTimeMap: ((Int) -> Float)? = nil,
        invRefTimeMap: ((Float) -> Int)? = nil
    )
    {
        self.follower = follower
        self.processor = processor
        self.refTimeMap = refTimeMap
        self.invRefTimeMap = invRefTimeMap
    }
    
    public init(
        follower: OnlineTimeWarping,
        processor: Processor,
        refTimeMap: IndexToTimeMap,
        invRefTimeMap: TimeToIndexMap
    )
    {
        self.follower = follower
        self.processor = processor
        self.refTimeMap = refTimeMap.callAsFunction
        self.invRefTimeMap = invRefTimeMap.callAsFunction
    }
    
    public mutating func callAsFunction(frame: [Float]) {
        let inputFeatures: [Float] = self.processor.process(frame: frame)
        self.follower(inputFeatures: inputFeatures)
    }

    public mutating func reset(currentPosition: Int) {
        self.currentPosition = currentPosition
        // TODO: Reset cost matrix?
    }
}
