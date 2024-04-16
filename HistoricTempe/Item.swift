//
//  Item.swift
//  HistoricTempe
//
//  Created by Dinh Phuc Nguyen on 4/16/24.
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
