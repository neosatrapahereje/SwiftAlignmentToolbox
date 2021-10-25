//
//  OsUtils.swift
//  Utilities for reading and writing data
//
//  Created by Carlos Eduardo Cancino-Chacón on 21.09.21.
//

import Foundation
import Surge
import Accelerate

func writeToFile(data: Data, url: URL , compress: Bool=true){
    // Adapted from https://stackoverflow.com/a/57268481    
    
    // if file exists then write data
    if FileManager.default.fileExists(atPath: url.path) {
        if let fileHandle = FileHandle(forWritingAtPath: url.path) {
            // seekToEndOfFile, writes data at the last of file(appends not override)
            // fileHandle.seekToEndOfFile()
            if compress{
                fileHandle.write(compressData(data: data)!)
            } else {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        }
        else {
            print("Can't open file to write.")
        }
    }
    else {
        // if file does not exist write data for the first time
        do{
            if compress {
                let cData = compressData(data: data)!
                try cData.write(to: url, options: .atomic)
            } else {
                try data.write(to: url, options: .atomic)
            }
        }catch {
            print("Unable to write in new file: \(error.localizedDescription)")
        }
    }
}

func writeToFile(data: Data, fileName: String, compress: Bool = true) {
    let url =  URL(fileURLWithPath: fileName)
    writeToFile(data: data, url: url, compress: compress)
}

func readFromFile(fileName: String) -> Data? {
    
    let bdata = NSData(contentsOfFile: fileName)! as Data
    do {
        // Try to decompress the file
        let dData = try decompressData(compressedData: bdata)!
        return dData
    } catch {
        // print(error.localizedDescription)
        return bdata
    }
}


func compressData(data: Data) -> Data?{
    do {
        let compressedData = try (data as NSData).compressed(using: .lzfse)
        // use your compressed data
        return compressedData as Data
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func decompressData(compressedData: Data) throws -> Data? {
    do {
        let decompressedData = try (compressedData as NSData).decompressed(using: .lzfse) as Data
        return decompressedData
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

public func savedMatrixSizeMB(rows: Int, columns: Int) -> Float {
    let fileSize: Float = Float(rows * columns * 32) * 0.000000125
    return fileSize
}


public func csvToMatrix(url: URL, delimiter: Substring.Element = ",", skipRows: Int? = nil) -> Matrix<Float>? {
    var matrix: Matrix<Float>? = nil
    let columns: Int
    let rows: Int
    let startRow: Int
    do {
        let file = try String(contentsOf: url)
        let lines: Array<Substring> = file.split(separator: "\n")
        if skipRows != nil {
            assert(skipRows! > 0)
            rows = lines.count - skipRows!
            startRow = skipRows!
        } else {
            rows = lines.count
            startRow = 0
        }
        columns = lines[0].split(separator: delimiter).count
        matrix = Matrix(rows: rows,
                        columns: columns,
                        repeatedValue: Float(0))
        
        for i in startRow..<rows {
            for (j, cl) in lines[i].split(separator: delimiter).enumerated() {
                matrix![i - startRow, j] = Float(cl)!
            }
        }
        
    } catch {
        print(error)
    }
    return matrix
}

public func csvToMatrix(path: String, delimiter: Substring.Element = ",", skipRows: Int? = nil) -> Matrix<Float>? {
    let url: URL = URL(fileURLWithPath: path)
    let matrix: Matrix<Float>? = csvToMatrix(
        url: url,
        delimiter: delimiter,
        skipRows: skipRows
    )
    return matrix
}

// from https://stackoverflow.com/questions/69622312/how-can-i-get-type-of-variable-in-function-using-template
func secureInput<T>(forType type: T.Type) { print(type) }
