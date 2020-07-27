//
//  ObjectEncoderProtocol.swift
//  CopyPasteExtension
//
//  Created by Yolo on 27/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

protocol ObjectEncoderProtocol: Codable {
    func encodeObject() throws -> Data?
    static func decodeObject(from data: Data) throws -> ObjectEncoderProtocol
}
