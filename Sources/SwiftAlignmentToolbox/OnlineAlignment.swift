//
//  OnlineAlignment.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 15.09.21.
//
// TODO: Update OnlineTimeWarping to work with the new Matrix class

import Foundation
import Accelerate
import Surge


public class OnlineTimeWarping{
    // Online Time Warping is the on-line version of
    // Dynamic Time Warping
    public let referenceFeatures: Matrix<Float>
    public var currentPosition: Int = 0
    public var globalCostMatrix: Matrix<Float>
    public var globalCostMatrix0: Array<Float>
    public var globalCostMatrix1: Array<Float>
    let infCost: Array<Float>
    public let stepSize: Int
    public let windowSize: Int
    public var inputIndex: Int = 0
    public let nRef: Int
    public var warpingPath: [[Int]]
    public let localDistance : ([Float], [Float]) -> Float
    public var windowCost: [Float]
    
    public init(
        referenceFeatures: Matrix<Float>,
        stepSize: Int = 5,
        windowSize: Int = 100,
        localDistance: String = "L1"
    ){
        
        // The pre-computed reference features
        self.referenceFeatures = referenceFeatures
        
        // Number of rows in the reference features
        self.nRef = referenceFeatures.count
        
        // Initialize the global cost matrix with "infinite"
        self.globalCostMatrix = Matrix<Float>(rows: self.nRef + 1,
                                              columns: 2,
                                              repeatedValue: Float.infinity)
        self.infCost = Array<Float>(repeating: Float.infinity,
                                    count: self.nRef + 1)
        self.globalCostMatrix0 = self.infCost
        self.globalCostMatrix1 = self.infCost
        self.stepSize = stepSize
        self.windowSize = windowSize
        self.currentPosition = 0
        self.warpingPath = []
        
        if localDistance == "L1" {
            self.localDistance = l1Distance
        }
        else if localDistance == "Cosine" {
            self.localDistance = CosineDistance
        }
        else {
            self.localDistance = EuclideanDistance
        }
        
        self.windowCost = Array<Float>(
            repeating: Float(0),
            count: 2 * self.windowSize)
    }
    
    public func step(inputFeatures: [Float]){
        // Get current window
        let (lower, upper) = self.selectWindow(currentPosition: self.currentPosition)
        
        // initial minimum cost to compare
        var minCost: Float = Float.infinity
    
        var minIndex: Int = 0
        
        self.vdist(start: lower, end: upper, inputFeatures: inputFeatures)
    
        for (idx, scoreIndex) in (lower..<upper).enumerated() {
            
            // Special case: cell (0, 0)
            if scoreIndex == 0 && self.inputIndex == 0 {
                // self.globalCostMatrix[1, 1] = windowCost.reduce(0, +)
                // self.globalCostMatrix[1, 1] = Surge.sum(windowCost)
                self.globalCostMatrix1[1] = Surge.sum(windowCost)
                // minCost = self.globalCostMatrix[1, 1]
                minCost = self.globalCostMatrix1[1]
                minIndex = 0
                continue
            }
            // get the previously computed local cost
            let localDist: Float = windowCost[idx]
            
            // update global costs
            /*
            let dist1: Float = self.globalCostMatrix[scoreIndex, 1] + localDist
            let dist2: Float = self.globalCostMatrix[scoreIndex + 1, 0] + localDist
            let dist3: Float = self.globalCostMatrix[scoreIndex, 0] + localDist
            */
            let dist1: Float = self.globalCostMatrix1[scoreIndex] + localDist
            let dist2: Float = self.globalCostMatrix0[scoreIndex + 1] + localDist
            let dist3: Float = self.globalCostMatrix0[scoreIndex] + localDist
            let minDist: Float = min(dist1, dist2, dist3)
            // self.globalCostMatrix[scoreIndex + 1, 1] = minDist
            self.globalCostMatrix1[scoreIndex + 1] = minDist
            
            // Normalize cost (as proposed by Arzt et al.)
            let normCost = minDist / Float(self.inputIndex + scoreIndex + 1)
            
            // Check if new cell has lower costs and might be the current position
            if normCost < minCost {
                minCost = normCost
                minIndex = scoreIndex
            }
        }
        
        // Is there a better way to do this?
        // self.globalCostMatrix[column: 0] = self.globalCostMatrix[column: 1]
        // self.globalCostMatrix[column: 1] *= (1e-6 + Float.infinity)
        self.globalCostMatrix0 = self.globalCostMatrix1
        self.globalCostMatrix1 = self.infCost
        /*
        for i in Array(0..<self.nRef){
            self.globalCostMatrix[i, 0] = self.globalCostMatrix[i, 1]
            self.globalCostMatrix[i, 1] *= (1e-6 + Float.infinity)
        }
         */
        
        // Adapt currentPosition: do not go backwards, but also go a maximum of N steps forward
        self.currentPosition = min(max(self.currentPosition, minIndex),
                                   self.currentPosition + self.stepSize)
        
        // Update warping path
        self.warpingPath.append([self.inputIndex, self.currentPosition])
        
        // Update input index
        self.inputIndex += 1
        
    }
    
    func selectWindow(currentPosition: Int) -> (Int, Int) {
        // Select window
        let lower: Int = max(currentPosition - self.windowSize, 0)
        let upper: Int = min(currentPosition + self.windowSize, self.nRef)
        // let window: [Int] = Array(lower..<upper)
        return (lower, upper)
    }
    
    /*
    func vdist(start: Int, end: Int,
               inputFeatures: [Float]) -> [Float]{
        // Compute the distance between a vector and each of the rows of a matrix
        var dist: [Float] = Array(repeating: 0, count: (end - start))
        for (i, rix) in (start..<end).enumerated() {
            dist[i] = self.localDistance(self.referenceFeatures[row: rix], inputFeatures)
        }
        return dist
    }
     */
    func vdist(start: Int, end: Int, inputFeatures: [Float]) {
        self.windowCost *= Float(0.0)
        for (i, rix) in (start..<end).enumerated() {
            self.windowCost[i] = self.localDistance(self.referenceFeatures[row: rix], inputFeatures)
        }
    }
}
