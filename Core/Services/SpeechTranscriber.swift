//
//  SpeechTransciberswift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import Foundation
import Speech

final class SpeechTranscriber {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var task: SFSpeechRecognitionTask?

    func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    func transcribe(url: URL) async throws -> String {
        guard let recognizer else { throw NSError(domain: "Speech", code: 1) }

        // 以前のタスクが残ってたら止める
        task?.cancel()
        task = nil

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        // 端末内認識を「試す」(できない端末/状況だと失敗するので、まずはfalseでもOK)
        // request.requiresOnDeviceRecognition = true

        return try await withCheckedThrowingContinuation { cont in
            self.task = recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                guard let result else { return }
                if result.isFinal {
                    cont.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
}
