//
//  OsUtils.swift
//  Utilities for reading and writing data
//
//  Created by Carlos Eduardo Cancino-Chacón on 21.09.21.
//

import Foundation
import Surge

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
