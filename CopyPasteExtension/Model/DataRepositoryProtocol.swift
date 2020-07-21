//
//  DataRepositoryProtocol.swift
//  CopyPasteExtension
//
//  Created by Yolo on 21/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

protocol DataRepositoryProtocol {
    static func dataId(withId id: Int) -> String
    func getData(withItemId itemId: Int) throws -> DataModelProtocol
    func setData(item: DataModelProtocol) throws
    func removeData(item: DataModelProtocol) throws
}
