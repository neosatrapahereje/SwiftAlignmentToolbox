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
