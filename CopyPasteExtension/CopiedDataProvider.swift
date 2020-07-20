//
//  CopiedDataProvider.swift
//  CopyPasteExtension
//
//  Created by Yolo on 03/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

class ClipboardDataProvider {
    private let defaults = UserDefaults.init(suiteName: AppPreferences.userDefaultsFilename)
    private var nextId: Int {
        for id in 1...AppPreferences.maxClipboardSize {
            guard let _ = defaults?.string(forKey: AppPreferences.dataId(withId: id)) else {
                return id
            }
        }
        return AppPreferences.maxClipboardSize
    }
    
    func getData(withItemId itemId: Int) throws -> DataModel {
        guard 1...AppPreferences.maxClipboardSize ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        let data = defaults?.string(forKey: AppPreferences.dataId(withId: itemId))
        if let data = data {
            return DataModel(id: itemId, data: data)
        }
        throw DataProviderError.noDataWithId
    }
    
    func allData() -> [DataModel] {
        var allData = [DataModel]()
        for id in 1...AppPreferences.maxClipboardSize {
            let data = defaults?.string(forKey: AppPreferences.dataId(withId: id))
            if let data = data {
                allData.append(DataModel(id: id, data: data))
            }
        }
        
        return allData
    }
    
    func setData(item: DataModel) throws {
        let itemId: Int! = item.id
        guard 1...AppPreferences.maxClipboardSize ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        defaults?.setValue(item.data, forKey: AppPreferences.dataId(withId: itemId))
    }
    
    func setData(withItemData itemData: String!) throws -> Int {
        let itemId = nextId
        guard 1...AppPreferences.maxClipboardSize ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        defaults?.setValue(itemData, forKey: AppPreferences.dataId(withId: itemId))
        return itemId
    }
    
    func removeData(withId itemId: Int) throws {
        guard 1...AppPreferences.maxClipboardSize ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        defaults?.removeObject(forKey: AppPreferences.dataId(withId: itemId))
    }
    
    func clearAllData() {
        for id in 1...AppPreferences.maxClipboardSize {
            try? removeData(withId: id)
        }
    }
}

//MARK:- AppPreferences extension
private extension AppPreferences {
    static func dataId(withId id: Int) -> String {
        return String(format: "%@_%d", AppPreferences.dataKeyBase, id)
    }
}

//MARK:- custom error
private enum DataProviderError: LocalizedError {
    case noDataWithId
    case idOutOfRange
    
    var errorDescription: String? {
        switch self {
        case .noDataWithId:
            return "There is no data with given id"
        case .idOutOfRange:
            return "The given id is invalid"
        }
    }
}
