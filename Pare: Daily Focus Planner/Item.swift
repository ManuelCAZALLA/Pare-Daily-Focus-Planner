//
//  Item.swift
//  Pare: Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 07/06/2026.
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
