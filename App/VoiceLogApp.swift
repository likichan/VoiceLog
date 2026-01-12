//
//  VoiceLogApp.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import SwiftUI
import SwiftData

@main
struct VoiceLogApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                DiaryScreen()
            }
        }
        .modelContainer(for: Item.self)
    }
}
