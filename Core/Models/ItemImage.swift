//
//  IItemImage.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2026/01/02.
//

import Foundation
import SwiftData

@Model
final class ItemImage {
    var originalPath: String
    var thumbPath: String
    var createdAt: Date

    // どのItemに紐づくか
    var item: Item?

    init(originalPath: String, thumbPath: String, createdAt: Date = .now) {
        self.originalPath = originalPath
        self.thumbPath = thumbPath
        self.createdAt = createdAt
    }
}
