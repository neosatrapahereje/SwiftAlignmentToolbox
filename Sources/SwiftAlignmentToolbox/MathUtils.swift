//
//  MathUtils.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 14.09.21.
//

import Foundation
import Accelerate


public struct Matrix<T: Codable>: Codable {
    let rows: Int, columns: Int
    var grid: [T]
    
    public enum CodingKeys: String, CodingKey {
        case rows
        case columns
        case grid
    }
    public init(rows: Int, columns: Int, defaultValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultValue, count: rows * columns) as [T]
    }
    public init(array: [[T]]){
        self.rows = array.count
        self.columns = array[0].count
        grid = array.flatMap{$0} as [T]
    }
    public init(array: [T]){
        // Consider a 1 dimensional array as a Matrix
        // This is just a convenience initialization, and it does not intend to be
        // mathematically correct.
        self.rows = array.count
        self.columns = 1
        grid = array as [T]
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.rows = try values.decode(Int.self, forKey: .rows)
        self.columns = try values.decode(Int.self, forKey: .columns)
        self.grid = try values.decode(Array<T>.self, forKey: .grid)
        /*
        var grid = Array<T>(repeating: 0 as! T, count: bdata.count/MemoryLayout<T>.stride)
        _ = grid.withUnsafeMutableBytes { bdata.copyBytes(to: $0) }
        self.grid = grid
         */
    }
    
    public func encode(from encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rows, forKey: .rows)
        try container.encode(self.columns, forKey: .columns)
        let rData = Data(bytes: self.grid,
                         count: self.grid.count * MemoryLayout<T>.stride)
        try container.encode(rData, forKey: .grid)
        
    }
    public func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    public subscript(_ row: Int, _ column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    public subscript(_ row: Range<Int>, _ column: Int) -> Matrix<T> {
        get {
            // There must be a way to do this correctly
            var newarray = Array(repeating: [grid[0]], count: row.count) as [[T]]
            for (i, rw) in row.enumerated() {
                newarray[i][0] = grid[(rw * columns) + column]
            }
            let outMatrix = Matrix(array:newarray)
            return outMatrix
        }
        set {
            for (i, rw) in row.enumerated() {
                grid[(rw * columns) + column] = newValue[i, 0]
            }
        }
    }
    public subscript(_ row: Int, _ column: Range<Int>) -> Matrix<T> {
        // Think of broadcasting rules?
        get {
            // There must be a way to do this correctly with pointers instead o
            // creating a new array
            var newarray = [Array(repeating: grid[0], count: column.count)] as [[T]]
            for (i, col) in column.enumerated() {
                newarray[0][i] = grid[(row * columns) + col]
            }
            let outMatrix = Matrix(array:newarray)
            return outMatrix
        }
        set (newValue) {
            for (i, col) in column.enumerated() {
                grid[(row * columns) + col] = newValue[0, i]
            }
        }
    }
    public subscript(_ row: Int, _ column: Range<Int>) -> Array<T> {
        // Think of broadcasting rules?
        get {
            // There must be a way to do this correctly with pointers instead o
            // creating a new array
            var newarray = Array(repeating: grid[0], count: column.count) as [T]
            for (i, col) in column.enumerated() {
                newarray[i] = grid[(row * columns) + col]
            }
            // let outMatrix = Matrix(array:newarray)
            return newarray
        }
        set (newValue) {
            for (i, col) in column.enumerated() {
                grid[(row * columns) + col] = newValue[i]
            }
        }
    }
    public subscript(_ row: Range<Int>, _ column: Range<Int>) -> Matrix<T> {
        // Think of broadcasting rules?
        get {
            // There must be a way to do this correctly with pointers instead o
            // creating a new array
            var newarray = Array(repeating: Array(repeating: grid[0], count: column.count), count: row.count) as [[T]]
            
            for (i, rw) in row.enumerated(){
                for (j, col) in column.enumerated() {
                    newarray[i][j] = grid[(rw * columns) + col]
                }
            }
            let outMatrix = Matrix(array:newarray)
            return outMatrix
        }
        set {
            for (i, rw) in row.enumerated() {
                for (j, col) in column.enumerated() {
                    grid[(rw * columns) + col] = newValue[i, j]
                }
            }
        }
    }
    public func toArray() -> [[T]] {
        // There must be a better way to do this
        var outArray: [[T]] = []
        for i in 0..<self.rows {
            var row: Array<T> = []
            for j in 0..<self.columns {
                row.append(self[i, j])
            }
            outArray.append(row)
        }
        return outArray
    }
}

/*
func transpose<T>(input: [[T]]) -> [[T]] {
    if input.isEmpty { return [[T]]() }
    let count = input[0].count
    var out = [[T]](count: count, repeatedValue: [T]())
    for outer in input {
        for (index, inner) in outer.enumerate() {
            out[index].append(inner)
        }
    }

    return out
}
 */

public func transpose<T>(_ input: [[T]]) -> [[T]] {
    // Transpose a 2D array
    if input.isEmpty { return [[T]]() }
    let count = input[0].count
    var out = [[T]](repeating: [T](), count: count)
    for outer in input {
        for (index, inner) in outer.enumerated() {
            out[index].append(inner)
        }
    }
    return out
}


/* Local Distances */
public func l1Distance(_ x: [Float], _ y: [Float]) -> Float {
    // L1 (Manhattan) Distance between two vectors
    var dist: Float = 0
    for (i, val) in x.enumerated(){
        dist += abs(y[i] - val)
    }
    return dist
}

public func CosineDistance(_ x: [Float], _ y: [Float]) -> Float {
    // Cosine Distance between two vectors
    var dist: Float = 0
    var dot: Float = 0
    var normX: Float = 0
    var normY: Float = 0
    var cos: Float = 0
    
    dot = vDSP.dot(x, y)
    normX = vNorm(x)
    normY = vNorm(y)
    
    cos = dot / (normX * normY + 1e-10)
    
    dist = 1 - cos
    return dist
}

public func EuclideanDistance(_ x: [Float], _ y: [Float]) -> Float {
    // Euclidean Distance
    var dist: Float = 0
    dist = sqrt(vDSP.distanceSquared(x, y))
    return dist
}

/* Utilities */
public func vNorm(_ x: [Float]) -> Float {
    // Norm of a vector
    // Probably this method exists somewhere else...
    var norm : Float = 0
    norm = sqrt(vDSP.dot(x, x))
    return norm
}


