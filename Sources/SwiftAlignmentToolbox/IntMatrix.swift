//
//  File.swift
//  
//
//  Created by Carlos Eduardo Cancino-Chacón on 22.10.21.
//

import Foundation


public struct IntMatrix {
    public let rows: Int
    public let columns: Int
    public var grid: [Int]
    
    public init(rows: Int, columns: Int, repeatedValue: Int) {
        self.rows = rows
        self.columns = columns
        self.grid = [Int](repeating: repeatedValue, count: rows * columns)
    }
    
    // TODO: Add more initializations/
    
}


// Copy from Surge
extension IntMatrix: Sequence {
    public func makeIterator() -> AnyIterator<ArraySlice<Int>> {
        let endIndex = rows * columns
        var nextRowStartIndex = 0

        return AnyIterator {
            if nextRowStartIndex == endIndex {
                return nil
            }

            let currentRowStartIndex = nextRowStartIndex
            nextRowStartIndex += self.columns

            return self.grid[currentRowStartIndex..<nextRowStartIndex]
        }
    }
}

// MARK: - Collection

extension IntMatrix {
    // MARK: - Subscript

    public subscript(row: Int, column: Int) -> Int {
        get {
            assert(indexIsValidForRow(row, column: column))
            return grid[(row * columns) + column]
        }

        set {
            assert(indexIsValidForRow(row, column: column))
            grid[(row * columns) + column] = newValue
        }
    }

    public subscript(row row: Int) -> [Int] {
        get {
            assert(row < rows)
            let startIndex = row * columns
            let endIndex = row * columns + columns
            return Array(grid[startIndex..<endIndex])
        }

        set {
            assert(row < rows)
            assert(newValue.count == columns)
            let startIndex = row * columns
            let endIndex = row * columns + columns
            grid.replaceSubrange(startIndex..<endIndex, with: newValue)
        }
    }

    public subscript(column column: Int) -> [Int] {
        get {
            var result = [Int](repeating: 0, count: rows)
            for i in 0..<rows {
                let index = i * columns + column
                result[i] = self.grid[index]
            }
            return result
        }

        set {
            assert(column < columns)
            assert(newValue.count == rows)
            for i in 0..<rows {
                let index = i * columns + column
                grid[index] = newValue[i]
            }
        }
    }

    private func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}


extension IntMatrix: Collection {
    public subscript(_ row: Int) -> ArraySlice<Int> {
        let startIndex = row * columns
        let endIndex = startIndex + columns
        return self.grid[startIndex..<endIndex]
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return self.rows
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }
}

extension IntMatrix: Equatable {}
public func == (lhs: IntMatrix, rhs: IntMatrix) -> Bool {
    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
}
