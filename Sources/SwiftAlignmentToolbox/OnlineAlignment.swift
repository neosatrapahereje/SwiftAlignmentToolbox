//
//  OnlineAlignment.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 15.09.21.
//
// TODO: Update OnlineTimeWarping to work with the new Matrix class

import Foundation
import Accelerate


class OnlineTimeWarping{
    // Online Time Warping is the on-line version of
    // Dynamic Time Warping
    let referenceFeatures: [[Float]]
    var currentPosition: Int = 0
    var globalCostMatrix: [[Float]]
    let stepSize: Int
    let windowSize: Int
    var inputIndex: Int = 0
    let nRef: Int
    var warpingPath: [[Int]]
    let localDistance : ([Float], [Float]) -> Float
    
    init(_ referenceFeatures: [[Float]],
         _ stepSize: Int = 5,
         _ windowSize: Int = 100,
         _ localDistance: String = "L1"){
        
        // The pre-computed reference features
        self.referenceFeatures = referenceFeatures
        
        // Number of rows in the reference features
        self.nRef = referenceFeatures.count
        
        // Initialize the global cost matrix with "infinite"
        self.globalCostMatrix = Array(
            repeating: Array(repeating: Float.infinity, count: 2),
            count: self.nRef + 1
        )
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
    }
    
    func step(inputFeatures: [Float]){
        // Get current window
        let (lower, upper, window) = self.selectWindow(currentPosition: self.currentPosition)
        
        // initial minimum cost to compare
        var minCost: Float = Float.infinity
    
        var minIndex: Int = 0
        
        let windowCost = self.vdist(
            referenceFeatures: Array(self.referenceFeatures[lower..<upper]),
            inputFeatures: inputFeatures)
    
        for (idx, scoreIndex) in window.enumerated() {
            // print(idx, scoreIndex)
            
            // Special case: cell (0, 0)
            if scoreIndex == 0 && self.inputIndex == 0 {
                self.globalCostMatrix[1][1] = windowCost.reduce(0, +)
                minCost = self.globalCostMatrix[1][1]
                minIndex = 0
                continue
            }
            // get the previously computed local cost
            let localDist: Float = windowCost[idx]
            
            // update global costs
            let dist1: Float = self.globalCostMatrix[scoreIndex][1] + localDist
            let dist2: Float = self.globalCostMatrix[scoreIndex + 1][0] + localDist
            let dist3: Float = self.globalCostMatrix[scoreIndex][0] + localDist
            
            let minDist: Float = min(dist1, dist2, dist3)
            self.globalCostMatrix[scoreIndex + 1][1] = minDist
            
            // Normalize cost (as proposed by Arzt et al.)
            let normCost = minDist / Float(self.inputIndex + scoreIndex + 1)
            
            // Check if new cell has lower costs and might be the current position
            if normCost < minCost {
                minCost = normCost
                minIndex = scoreIndex
            }
        }
        
        // Is there a better way to do this?
        for i in Array(0..<self.nRef){
            self.globalCostMatrix[i][0] = self.globalCostMatrix[i][1]
            self.globalCostMatrix[i][1] =  Float.infinity
        }
        
        // Adapt currentPosition: do not go backwards, but also go a maximum of N steps forward
        self.currentPosition = min(max(self.currentPosition, minIndex),
                                   self.currentPosition + self.stepSize)
        
        // Update warping path
        self.warpingPath.append([self.inputIndex, self.currentPosition])
        
        // Update input index
        self.inputIndex += 1
        
    }
    
    func selectWindow(currentPosition: Int) -> (Int, Int, [Int]) {
        // Select window
        let lower: Int = max(currentPosition - self.windowSize, 0)
        let upper: Int = min(currentPosition + self.windowSize, self.nRef)
        let window: [Int] = Array(lower..<upper)
        return (lower, upper, window)
    }
    
    func vdist(referenceFeatures: [[Float]],
               inputFeatures: [Float]) -> [Float]{
        // Compute the distance between a vector and each of the rows of a matrix
        var dist: [Float] = Array(repeating: 0, count: referenceFeatures.count)
        for (i, row) in referenceFeatures.enumerated() {
            dist[i] = self.localDistance(row, inputFeatures)
        }
        return dist
    }
}


