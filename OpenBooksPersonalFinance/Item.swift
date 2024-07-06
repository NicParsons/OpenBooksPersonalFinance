//
//  Item.swift
//  OpenBooksPersonalFinance
//
//  Created by Nicholas Parsons on 6/7/2024.
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
