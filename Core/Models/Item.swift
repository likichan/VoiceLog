//  Entryとして使う
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
    var text: String
    var deletedAt: Date?

    // ✅ 複数画像（ItemImageにファイル名を持たせる）
    @Relationship(deleteRule: .cascade)
    var images: [ItemImage] = []

    init(timestamp: Date = .now, text: String, deletedAt: Date? = nil) {
        self.timestamp = timestamp
        self.text = text
        self.deletedAt = deletedAt
    }
}
