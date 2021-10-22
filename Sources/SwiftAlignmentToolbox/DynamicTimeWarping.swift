//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 22.10.21.
//

import Foundation
import Surge


public func dynamicTimeWarping(
    X: Matrix<Float>,
    Y: Matrix<Float>,
    window:[[Int]]? = nil,
    localDistance: ([Float], [Float]
) -> Float) -> ([[Int]], Float)
{
    // Vanilla Dynamic Time Warping
    let M: Int = X.rows
    let N: Int = Y.rows
    var path: [[Int]] = []
    var dtwd: Float = 0
    var searchWindow: [[Int]]
    
    // Create a full window if none is given
    if window != nil {
        searchWindow =  window!
    } else {
        searchWindow = Array<[Int]>(repeating: Array<Int>(repeating: 0, count: 2), count: N * M)
        var rowAcc: Int = 0
        for n in 0..<N {
            for m in 0..<M {
                rowAcc = m * N + n
                searchWindow[rowAcc][0] = m
                searchWindow[rowAcc][1] = n
            }
        }
    }
    
    let L: Int = searchWindow.count
    
    // Initialize accumulatedCostMatrix and related indices
    var accCostMatrix: Matrix<Float> = Matrix(rows: M + 1, columns: N + 1, repeatedValue: Float.infinity)
    accCostMatrix[0, 0] = Float(0)
    var IndicesI: IntMatrix = IntMatrix(
        rows: M + 1,
        columns: N + 1,
        repeatedValue: 0
    )
    var IndicesJ: IntMatrix = IntMatrix(
        rows: M + 1,
        columns: N + 1,
        repeatedValue: 0
    )
    var pathStep: [Int] = [0, 0]
    var cost: Float = 0
    var i: Int = 0
    var j: Int = 0
    var insi: Int = 0
    var insj: Int = 0
    var deli: Int = 0
    var delj: Int = 0
    var mati: Int = 0
    var matj: Int = 0
    var bestIdx: Int? = 0
    var pathCandidatesI = Array<Int>(repeating: 0, count: 3)
    var pathCandidatesJ = Array<Int>(repeating: 0, count: 3)
    var bestCost: Float? = 0
    var costCandidates = Array<Float>(repeating: 0, count: 3)
    for l in 0..<L {
        // Current indices
        i = searchWindow[l][0] + 1
        j = searchWindow[l][1] + 1
        
        // Indices of the candidates
        // Insertion
        insi = i - 1
        insj = j
        // Deletion
        deli = i
        delj = j - 1
        // Match
        mati = i - 1
        matj = j - 1
        
        // Compute local cost
        cost = localDistance(X[row: mati], Y[row: matj])
        
        // Indices of the path candidates
        pathCandidatesI[0] = mati
        pathCandidatesJ[0] = matj
        pathCandidatesI[1] = insi
        pathCandidatesJ[1] = insj
        pathCandidatesI[2] = deli
        pathCandidatesJ[2] = delj
        
        // Indices of the cost candidates
        costCandidates[0] = accCostMatrix[mati, matj]
        costCandidates[1] = accCostMatrix[insi, insj]
        costCandidates[2] = accCostMatrix[deli, delj]
        
        // Index and cost of the best path
        (bestIdx, bestCost) = costCandidates.argmin()
        
        // Update accumulated cost matrix and track path
        accCostMatrix[i, j] = cost + bestCost!
        IndicesI[i, j] = pathCandidatesI[bestIdx!]
        IndicesJ[i, j] = pathCandidatesJ[bestIdx!]
    }
    
    // Dtwd distance
    dtwd = accCostMatrix[M, N]
    
    
    // Backtracking
    var m: Int = M
    var n: Int = N
    
    while m != 0 && n != 0 {
        pathStep[0] = m - 1
        pathStep[1] = n - 1
        path.append(pathStep)
        m = IndicesI[m, n]
        n = IndicesJ[m, n]
    }
    path.reverse()
    
    return (path, dtwd)
}
