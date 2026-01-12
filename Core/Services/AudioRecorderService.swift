//
//  RecordingService.swift
//  VoiceLog
//
//  Created by 後藤吏希 on 2025/12/29.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioRecorderService: NSObject, ObservableObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorderService()

    @Published var isRecording: Bool = false
    @Published var elapsed: TimeInterval = 0

    private var recorder: AVAudioRecorder?
    @MainActor private var timer: Timer?
    private(set) var lastRecordedURL: URL?

    func requestMicPermission() async -> Bool {
        await withCheckedContinuation { cont in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            }
        }
    }

    func start() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [.defaultToSpeaker, .allowBluetoothHFP, .allowBluetoothA2DP]
        )
        try session.setActive(true)

        let url = makeNewFileURL()
        lastRecordedURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let r = try AVAudioRecorder(url: url, settings: settings)
        r.delegate = self
        r.record()

        recorder = r
        isRecording = true
        startTimer()
    }

    func stop() -> URL? {
        recorder?.stop()
        recorder = nil
        isRecording = false
        stopTimer()

        return lastRecordedURL
    }

    // MARK: - Shortcut Entry Points
    func startFromShortcut() async {
        do {
            try start()
        } catch {
            // Ignore or log as needed; intents can treat failures silently
        }
    }

    func stopFromShortcut() async {
        _ = stop()
    }

    // MARK: - Timer
    private func startTimer() {
        elapsed = 0
        timer?.invalidate()
        // Schedule on the main run loop to ensure callbacks occur on the main thread.
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            // Ensure mutation of @MainActor state happens on the main actor.
            Task { @MainActor in
                self.elapsed += 1
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - File
    private func makeNewFileURL() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = "voicelog_\(Int(Date().timeIntervalSince1970)).m4a"
        return dir.appendingPathComponent(name)
    }
}

