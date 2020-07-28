//
//  CopiedDataProvider.swift
//  CopyPasteExtension
//
//  Created by Yolo on 03/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

final class ClipboardRepository {
    let defaults: UserDefaults?
    
    init(defaults: UserDefaults?) {
        self.defaults = defaults
    }
    
    func setData(withItemData itemData: String!) throws -> Int {
        let itemId = nextId
        try setData(item: DataModel(id: itemId, data: itemData))
        return itemId
    }
    
    func removeData(withId itemId: Int) throws {
        guard idRange ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        defaults?.removeObject(forKey: ClipboardRepository.dataId(withId: itemId))
    }
    
    private func optimizeIds(data: [DataModel]) -> [DataModel] {
        var optimizedData = [DataModel]()
        data.enumerated().forEach { (index, element) in
            optimizedData.append(DataModel(id: index+1, data: element.data))
        }
        
        return optimizedData
    }
    
    private func setData(data: [DataModelProtocol]) throws {
        clearAllData()
        try data.forEach { dataModel in
            try setData(item: dataModel)
        }
    }
    
    private func clearAllData() {
        for id in idRange {
            try? removeData(withId: id)
        }
    }
}

extension ClipboardRepository {
    private var nextId: Int {
        for id in idRange {
            guard let _ = defaults?.string(forKey: ClipboardRepository.dataId(withId: id)) else {
                return id
            }
        }
        return AppPreferences.getMaxClipboardSize
    }
    
    private var idRange: ClosedRange<Int> {
        return 1...AppPreferences.getMaxClipboardSize
    }
}

//MARK:- DataRepositoryProtocol protocol
extension ClipboardRepository: DataRepositoryProtocol {
    static func dataId(withId id: Int) -> String {
        return String(format: "%@_%d", AppPreferences.dataKeyBase, id)
    }
    
    func allData() throws -> [DataModelProtocol] {
        var allData = [DataModel]()
        for id in idRange {
            let data = defaults?.string(forKey: ClipboardRepository.dataId(withId: id))
            if let data = data {
                allData.append(DataModel(id: id, data: data))
            }
        }
        
        let optimizedData = optimizeIds(data: allData)
        let sortedAllData = allData.sorted(by: { $0.id < $1.id })
        if sortedAllData == optimizedData {
            return sortedAllData
        } else {
            try setData(data: optimizedData)
            return optimizedData
        }
    }
    
    func getData(withItemId itemId: Int) throws -> DataModelProtocol {
        guard idRange ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        guard let data = defaults?.string(forKey: ClipboardRepository.dataId(withId: itemId)) else {
            throw DataProviderError.noDataWithId
        }
        return DataModel(id: itemId, data: data)
    }
    
    func setData(item: DataModelProtocol) throws {
        let itemId: Int! = item.id
        guard idRange ~= itemId else {
            throw DataProviderError.idOutOfRange
        }
        
        guard item.data.count > 0 else {
            throw DataProviderError.noDataWithId
        }
        
        defaults?.setValue(item.data, forKey: ClipboardRepository.dataId(withId: itemId))
    }
    
    func removeData(item: DataModelProtocol) throws {
        try removeData(withId: item.id)
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
