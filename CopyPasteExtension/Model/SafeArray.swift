//
//  SafeArray.swift
//  CopyPasteExtension
//
//  Created by Yolo on 03/08/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

final class SafeArray<T> {
    private let size: Int
    private var array: [T?]
    
    init(arraySize: Int) {
        self.size = arraySize
        self.array = Array(repeating: nil, count: arraySize)
    }
    
    init(array: [T?]) {
        self.size = array.count
        self.array = array
    }
    
    subscript(index: Int) -> T? {
        get {
            if arrayCheck(for: index) {
                return array[index]
            }
            return nil
        }
        set(item) {
            if arrayCheck(for: index) {
                array[index] = item
            }
        }
    }
}

extension SafeArray {
    private func arrayCheck(for index: Int) -> Bool {
        guard index.inRange(from: 0, to: array.count) else {
            return false
        }
        return true
    }
}

extension SafeArray {
    func firstIndex(where predicate: (T?) -> Bool) -> Int? {
        return array.firstIndex(where: predicate)
    }
    
    func first(where predicate: (T?) -> Bool) -> T?? {
        return array.first(where: predicate)
    }
    
    func filter(_ isIncluded: (T?) -> Bool) -> [T?] {
        return array.filter(isIncluded)
    }
    
    func filtered(_ isIncluded: (T?) -> Bool) {
        array = filter(isIncluded)
    }
}

extension SafeArray where T == DataModelProtocol? {
    func swap(_ firstIndex: Int, _ secondIndex: Int) {
        guard
            arrayCheck(for: firstIndex),
            arrayCheck(for: secondIndex),
            let item1 = array[firstIndex],
            let item2 = array[secondIndex],
            let firstItem = item1,
            let secondItem = item2
            else {
            return
        }
        
        let originalFirstItem = DataModel(id: secondItem.id, data: firstItem.data)
        let originalSecondItem = DataModel(id: firstItem.id, data: secondItem.data)
        array[firstIndex] = originalSecondItem
        array[secondIndex] = originalFirstItem
    }
}

extension SafeArray where T == DataModelProtocol? {
    func isEqualTo(_ otherArray: SafeArray) -> Bool {
        let difference = zip(array, otherArray.array).filter {
            switch ($0, $1) {
            case let (item1??, item2??):
                return !(item1.id == item2.id && item1.data == item2.data)
            case (nil, nil):
                return false
            default:
                return true
            }
        }

        return difference.isEmpty
    }
}
