import AppIntents

@available(iOS 16.0, *)
struct StartRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "録音を開始"
    static var description = IntentDescription("VoiceLogで録音を開始します。")

    func perform() async throws -> some IntentResult {
        await AudioRecorderService.shared.startFromShortcut()
        return .result()
    }
}
