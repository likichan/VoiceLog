import AppIntents

@available(iOS 16.0, *)
struct StopRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "録音を停止"
    static var description = IntentDescription("VoiceLogの録音を停止します。")

    func perform() async throws -> some IntentResult {
        await AudioRecorderService.shared.stopFromShortcut()
        return .result()
    }
}
