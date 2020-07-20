//
//  DataModel.swift
//  CopyPasteExtension
//
//  Created by Yolo on 04/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

struct DataModel {
    var id: Int!
    var data: String!
    
    init(id: Int!, data: String!) {
        self.id = id
        self.data = data
    }
}

extension DataModel: Equatable {
    static func ==(dm1: DataModel, dm2: DataModel) -> Bool {
        return dm1.id == dm2.id && dm1.data == dm2.data
    }
}
