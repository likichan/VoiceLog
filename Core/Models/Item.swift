//
//  Item.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
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
