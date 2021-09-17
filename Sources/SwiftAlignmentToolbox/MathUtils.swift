//
//  MathUtils.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 14.09.21.
//

import Foundation
import Accelerate


struct Matrix<T: Codable>: Codable {
    let rows: Int, columns: Int
    var grid: [T]
    
    enum CodingKeys: String, CodingKey {
        case rows
        case columns
        case grid
    }
    init(rows: Int, columns: Int, defaultValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultValue, count: rows * columns) as [T]
    }
    init(array: [[T]]){
        self.rows = array.count
        self.columns = array[0].count
        grid = array.flatMap{$0} as [T]
    }
    
    init(from decoder: Decoder) throws {
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
    
    func encode(from encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rows, forKey: .rows)
        try container.encode(self.columns, forKey: .columns)
        let rData = Data(bytes: self.grid,
                         count: self.grid.count * MemoryLayout<T>.stride)
        try container.encode(rData, forKey: .grid)
        
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(_ row: Int, _ column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    subscript(_ row: Range<Int>, _ column: Int) -> Matrix<T> {
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
    subscript(_ row: Int, _ column: Range<Int>) -> Matrix<T> {
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
        set {
            for (i, col) in column.enumerated() {
                grid[(row * columns) + col] = newValue[0, i]
            }
        }
    }
    subscript(_ row: Range<Int>, _ column: Range<Int>) -> Matrix<T> {
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
}


/* Local Distances */
func l1Distance(_ x: [Float], _ y: [Float]) -> Float {
    // L1 (Manhattan) Distance between two vectors
    var dist: Float = 0
    for (i, val) in x.enumerated(){
        dist += abs(y[i] - val)
    }
    return dist
}

func CosineDistance(_ x: [Float], _ y: [Float]) -> Float {
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

func EuclideanDistance(_ x: [Float], _ y: [Float]) -> Float {
    // Euclidean Distance
    var dist: Float = 0
    dist = sqrt(vDSP.distanceSquared(x, y))
    return dist
}

/* Utilities */
func vNorm(_ x: [Float]) -> Float {
    // Norm of a vector
    // Probably this method exists somewhere else...
    var norm : Float = 0
    norm = sqrt(vDSP.dot(x, x))
    return norm
}


