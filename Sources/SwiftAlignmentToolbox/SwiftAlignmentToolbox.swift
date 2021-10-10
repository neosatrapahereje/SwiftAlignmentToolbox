import Foundation
import Surge

public enum SampleData {
    static public let audioExampleStereoURL = Bundle.module.url(forResource: "audio_example_stereo", withExtension: "wav")
    static public let audioExampleMonoURL = Bundle.module.url(forResource: "audio_example_mono", withExtension: "wav")
}

public struct OnlineAlignment {
    
    let follower: OnlineTimeWarping
    let processor: Processor
    
    public init(follower: OnlineTimeWarping, processor: Processor) {
        self.follower = follower
        self.processor = processor
    }
    
    public func step(frame: [Float]) {
        let inputFeatures: [Float] = self.processor.process(frame: frame)
        self.follower.step(inputFeatures: inputFeatures)
    }
}
