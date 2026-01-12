//
//  PhotoPicker.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2026/01/02.
//

import SwiftUI
import PhotosUI
import UIKit

struct PhotoPickerSheet: UIViewControllerRepresentable {
    var onImages: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 0 // ✅ 複数OK（0=無制限）

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerSheet
        init(_ parent: PhotoPickerSheet) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.dismiss()
                return
            }

            var images: [UIImage] = []
            let group = DispatchGroup()

            for r in results {
                let provider = r.itemProvider
                guard provider.canLoadObject(ofClass: UIImage.self) else { continue }

                group.enter()
                provider.loadObject(ofClass: UIImage.self) { obj, _ in
                    DispatchQueue.main.async {
                        if let img = obj as? UIImage {
                            images.append(img)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.parent.onImages(images)
                self.parent.dismiss()
            }
        }
    }
}
