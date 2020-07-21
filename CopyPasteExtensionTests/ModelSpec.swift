//
//  ModelSpec.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 15/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Quick
import Nimble

class ModelSpec: QuickSpec {
    override func spec() {
        describe("the data model") {
            context("comparing objects") {
                let model1 = DataModel(id: 42, data: "nana")
                let model2 = DataModel(id: 42, data: "nana")
                let model3 = DataModel(id: 24, data: "nana")
                let model4 = DataModel(id: 42, data: "sialala")
                
                describe("the objects are equal") {
                    it("all properties are the same") {
                        expect(model1) == model2
                    }
                }
                
                describe("objects are not equal") {
                    it("id is different") {
                        expect(model1) !== model3
                    }
                    
                    it("data is different") {
                        expect(model1) !== model4
                    }
                    
                    it("both properies are different") {
                        expect(model3) !== model4
                    }
                }
            }
            
            context("comparing arrays of objects") {
                let array1 = [DataModel(id: 42, data: "nana"), DataModel(id: 24, data: "sialala")]
                
                describe("arrays are equal") {
                    it("they have equal objects in the same order") {
                        let array2 = [DataModel(id: 42, data: "nana"), DataModel(id: 24, data: "sialala")]
                        expect(array1) == array2
                    }
                }
                
                describe("arrays are not equal") {
                    it("items are in different order") {
                        let array2 = [DataModel(id: 24, data: "sialala"), DataModel(id: 42, data: "nana")]
                        expect(array1) !== array2
                    }
                    
                    it("sizes are not the same") {
                        let array2 = [DataModel(id: 42, data: "nana")]
                        expect(array1) !== array2
                    }
                    
                    it("any of items is not equal") {
                        let array2 = [DataModel(id: 42, data: "nana"), DataModel(id: 24, data: "sia")]
                        expect(array1) !== array2
                    }
                }
            }
            
            context("getting an item from array") {
                let array = [0, 1, 2, 3]
                
                describe("item is returned") {
                    it("index is in range") {
                        expect(array.itemOrNil(index: array.count)).to(beNil())
                    }
                }
                
                describe("nil is returned") {
                    it("index is out of range") {
                        expect(array.itemOrNil(index: 1)).notTo(beNil())
                    }
                }
            }
        }
        
        describe("the data repository") {
            let mockDefaults = MockUserDefaults()
            let dataProvider = ClipboardRepository(defaults: mockDefaults)
            
            context("check data preprocessing") {
                describe("get data") {
                    it("with correct id") {
                        let mockDataModel = DataModel(id: 1, data: "nana")
                        mockDefaults.mockedStringReturn = { _ in
                            return mockDataModel.data
                        }
                        
                        let dataModel = try? dataProvider.getData(withItemId: mockDataModel.id)
                        expect(dataModel) == mockDataModel
                    }
                    
                    it("with incorrect id") {
                        let mockDataModelId = AppPreferences.maxClipboardSize+1
                        
                        let dataModel = try? dataProvider.getData(withItemId: mockDataModelId)
                        expect(dataModel).to(beNil())
                    }
                }
                
                describe("get all data") {
                    it("with id optimization") {
                        let mockDataModelArray = [
                            DataModel(id: 1, data: "a"),
                            DataModel(id: 3, data: "b"),
                            DataModel(id: 4, data: "c"),
                        ]
                        mockDefaults.mockedStringReturn = { key in
                            var resultData: String? = nil
                            mockDataModelArray.forEach { mockDataModel in
                                if key.contains("\(mockDataModel.id ?? -1)") {
                                    resultData = mockDataModel.data
                                }
                            }
                            return resultData
                        }
                        
                        let dataModelArray = try? dataProvider.allData()
                        expect(dataModelArray) !== mockDataModelArray
                    }
                    
                    it("without id optimization") {
                        let mockDataModelArray = [
                            DataModel(id: 1, data: "a"),
                            DataModel(id: 2, data: "b"),
                            DataModel(id: 3, data: "c"),
                        ]
                        mockDefaults.mockedStringReturn = { key in
                            var resultData: String? = nil
                            mockDataModelArray.forEach { mockDataModel in
                                if key.contains("\(mockDataModel.id ?? -1)") {
                                    resultData = mockDataModel.data
                                }
                            }
                            return resultData
                        }
                        
                        let dataModelArray = try? dataProvider.allData()
                        expect(dataModelArray) == mockDataModelArray
                    }
                }
                
                describe("set data") {
                    it("with correct id") {
                        let mockDataModel = DataModel(id: 1, data: "nana")
                        mockDefaults.mockedStringReturn = { _ in
                            return mockDataModel.data
                        }
                        
                        expect {
                            try dataProvider.setData(item: mockDataModel)
                        }.notTo(throwError())
                        
                    }
                    
                    it("with incorrect id") {
                        let mockDataModel = DataModel(id: AppPreferences.maxClipboardSize+1, data: "nana")
                        
                        expect {
                            try dataProvider.setData(item: mockDataModel)
                        }.to(throwError())
                    }
                }
                
                describe("remove data") {
                    it("with correct id") {
                        expect {
                            try dataProvider.removeData(withId: 1)
                        }.notTo(throwError())
                    }
                    
                    it("with incorrect id") {
                        expect {
                            try dataProvider.removeData(withId: AppPreferences.maxClipboardSize+1)
                        }.to(throwError())
                    }
                }
            }
        }
    }
}
