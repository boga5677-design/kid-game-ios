import Foundation
import AVFoundation

final class SpeechManager: ObservableObject {
    private let synth = AVSpeechSynthesizer()
    private var pending: DispatchWorkItem?

    private func preferredFemaleVoice(language: String) -> AVSpeechSynthesisVoice? {
        let exact = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == language }
        let family = exact.isEmpty
            ? AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(String(language.prefix(2))) }
            : exact

        let preferredNames: [String]
        if language.hasPrefix("zh") {
            preferredNames = ["meijia", "mei-jia", "美嘉"]
        } else {
            preferredNames = ["samantha", "ava", "allison", "susan", "nicky", "joelle"]
        }

        return family.max { lhs, rhs in
            func score(_ voice: AVSpeechSynthesisVoice) -> Int {
                let name = voice.name.lowercased()
                var value = voice.quality == .enhanced ? 300 : 0
                if let idx = preferredNames.firstIndex(where: { name.contains($0) }) {
                    value += 2000 - idx * 100
                }
                return value
            }
            return score(lhs) < score(rhs)
        } ?? AVSpeechSynthesisVoice(language: language)
    }

    func speak(_ text: String, after delay: TimeInterval = 0.5) {
        pending?.cancel()
        synth.stopSpeaking(at: .immediate)

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = self.preferredFemaleVoice(language: "zh-TW")
            utterance.rate = 0.45
            utterance.pitchMultiplier = 1.02
            utterance.volume = 0.92
            self.synth.speak(utterance)
        }
        pending = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }

    func replay(_ text: String) {
        speak(text, after: 0)
    }

    func stop() {
        pending?.cancel()
        synth.stopSpeaking(at: .immediate)
    }
}
