//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 19.09.21.
//
import Cocoa
import Foundation
import Surge


extension Matrix {
    public func toArray() -> [[Scalar]] where Scalar: FloatingPoint, Scalar: ExpressibleByFloatLiteral  {
        var outArray = Array<[Scalar]>(
            repeating: Array<Scalar>(repeating: 0.0, count: self.columns),
            count: self.rows
        )
        for i in 0..<self.rows {
            outArray[i].replaceSubrange(0..<self.columns, with: self[row: i])
        }
        return outArray
    }
}
 

public func readMatrixFromFile<T>(path: String) -> Matrix<T> {
    // let bdata = NSData(contentsOfFile: path)
    let bdata = readFromFile(fileName: path)
    let decoder = JSONDecoder()
    let decoded = try? decoder.decode(Matrix<T>.self, from: bdata!)
    return decoded!
}

extension Matrix {
    // This method does not really work well for large matrices...
    public func saveToFile(path: String, compress: Bool = true) {
        let pathAsURL = URL(fileURLWithPath: path)
        self.saveToFile(url: pathAsURL)
    }
    
    public func saveToFile(url: URL, compress: Bool = true) {
        if let encodedData = try? JSONEncoder().encode(self) {
            writeToFile(data: encodedData,
                        url: url,
                        compress: compress)
        }
    }
}

public class MatrixConfig: Codable {
    public let rows: Int
    public let columns: Int
    public let gridPath: String
    
    public enum CodingKeys: String, CodingKey {
        case rows
        case columns
        case gridPath
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.rows = try values.decode(Int.self, forKey: .rows)
        self.columns = try values.decode(Int.self, forKey: .columns)
        self.gridPath = try values.decode(String.self, forKey: .gridPath)
    }
    
    public func encode(from encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rows, forKey: .rows)
        try container.encode(self.columns, forKey: .columns)
        try container.encode(self.gridPath, forKey: .gridPath)
    }
    
    public init(rows: Int, columns: Int, gridPath: String) {
        self.rows = rows
        self.columns = columns
        self.gridPath = gridPath
    }
    
    public func saveToFile(url: URL) {
        if let encodedData = try? JSONEncoder().encode(self) {
            writeToFile(data: encodedData,
                        url: url,
                        compress: false)
        }
    }
    public func saveToFile(path: String) {
        let pathAsURL = URL(fileURLWithPath: path)
        self.saveToFile(url: pathAsURL)
    }
}

public func saveMatrix(matrix: Matrix<Float>, path: String) {
    let gridPath: String = path + ".bin"
    let gridURL: URL = URL(fileURLWithPath: gridPath)
    let matrixConf = MatrixConfig(
        rows: matrix.rows,
        columns: matrix.columns,
        gridPath: gridPath)
    matrixConf.saveToFile(path: path)
    
    saveMatrixGridToBin(matrix: matrix, url: gridURL)
}

func saveMatrixGridToBin(matrix: Matrix<Float>, url: URL) {
    let wData = Data(
        bytes: matrix.grid,
        count: matrix.grid.count * MemoryLayout<Float>.stride
    )
        do {
            try wData.write(to: url)
        } catch {
            print(error)
        }
}

public func readMatrixFromConfig<T>(path: String) -> Matrix<T> {
    var bdata: Data? = nil
    do {
        try bdata = NSData(contentsOfFile: path) as Data
    } catch {
        print(error)
    }
    let decoder = JSONDecoder()
    let decoded = try? decoder.decode(MatrixConfig.self, from: bdata!)
    
    let rData: Data = NSData(contentsOfFile: decoded!.gridPath)! as Data
    
    var grid = Array<T>(repeating: T(0), count: rData.count/MemoryLayout<T>.stride)
            _ = grid.withUnsafeMutableBytes { rData.copyBytes(to: $0) }
    
    let matrix: Matrix<T> = Matrix<T>(rows: decoded!.rows,
                                      columns: decoded!.columns,
                                      grid: grid)
    return matrix
}

extension Array where Element == Float {
    
    public func median() -> Float? {
        guard count > 0  else { return nil }
        let sortedArray = self.sorted()
        if count % 2 != 0 {
            return Float(sortedArray[count/2])
        } else {
            return Float(sortedArray[count/2] + sortedArray[count/2 - 1]) / 2.0
        }
    }
    
    public func argmin() -> (Int?, Float?) {
        guard self.count > 0 else {return (nil, nil)}
        var out: Float = Float.infinity
        var argmin: Int = 0
        for i in 0..<self.count {
            if self[i] < out {
                out = self[i]
                argmin = i
            }
        }
        return (argmin, out)
    }
}
