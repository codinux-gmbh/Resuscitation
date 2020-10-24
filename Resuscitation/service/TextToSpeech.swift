import AVFoundation


class TextToSpeech {
    
    func read(_ text: String) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode()) ?? AVSpeechSynthesisVoice(language: "en-GB")
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        } catch {
            NSLog("Could not start text-to-speech: \(error)")
        }
    }
    
}
