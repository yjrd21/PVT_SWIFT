//
//  Item.swift
//  PVT
//
//  Created by Daniel  Yuen on 1/6/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
