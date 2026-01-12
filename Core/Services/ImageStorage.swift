//
//  ImageStorage.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2026/01/02.
//

import Foundation
import UIKit

enum ImageStorageError: Error {
    case failedToCreateDirectory
    case failedToWrite
    case failedToLoad
}

struct SavedImagePaths {
    let originalPath: String   // 例: "media/original/XXXX.jpg"
    let thumbPath: String      // 例: "media/thumb/XXXX.jpg"
}

enum ImageStorage {

    // ベースフォルダ（Application Support/VoiceLog）
    private static var baseURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("VoiceLog", isDirectory: true)
    }

    private static var originalDir: URL { baseURL.appendingPathComponent("media/original", isDirectory: true) }
    private static var thumbDir: URL { baseURL.appendingPathComponent("media/thumb", isDirectory: true) }

    private static func ensureDirs() throws {
        let fm = FileManager.default
        for dir in [baseURL, originalDir, thumbDir] {
            if !fm.fileExists(atPath: dir.path) {
                do {
                    try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                } catch {
                    throw ImageStorageError.failedToCreateDirectory
                }
            }
        }
    }

    /// ✅ 原本 + サムネを保存（重くならないように縮小して保存）
    static func save(image: UIImage) throws -> SavedImagePaths {
        try ensureDirs()

        let id = UUID().uuidString
        let fileName = "\(id).jpg"

        // 原本：最大 2048px、品質 0.85
        let original = image.resized(maxPixel: 2048) ?? image
        guard let originalData = original.jpegData(compressionQuality: 0.85) else {
            throw ImageStorageError.failedToWrite
        }

        // サムネ：最大 320px、品質 0.7
        let thumb = image.resized(maxPixel: 320) ?? image
        guard let thumbData = thumb.jpegData(compressionQuality: 0.7) else {
            throw ImageStorageError.failedToWrite
        }

        let originalURL = originalDir.appendingPathComponent(fileName)
        let thumbURL = thumbDir.appendingPathComponent(fileName)

        do {
            try originalData.write(to: originalURL, options: [.atomic])
            try thumbData.write(to: thumbURL, options: [.atomic])
        } catch {
            throw ImageStorageError.failedToWrite
        }

        return SavedImagePaths(
            originalPath: "media/original/\(fileName)",
            thumbPath: "media/thumb/\(fileName)"
        )
    }

    static func loadImage(relativePath: String) -> UIImage? {
        let url = baseURL.appendingPathComponent(relativePath)
        return UIImage(contentsOfFile: url.path)
    }

    static func delete(relativePath: String) {
        let url = baseURL.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: url)
    }
}

private extension UIImage {
    func resized(maxPixel: CGFloat) -> UIImage? {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxPixel else { return self }

        let scale = maxPixel / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
