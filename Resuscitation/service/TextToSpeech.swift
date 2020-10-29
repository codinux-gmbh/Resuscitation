import AVFoundation


class TextToSpeech {
    
    private var session: AVAudioSession? = nil
    
    private var synthesizer: AVSpeechSynthesizer? = nil
    
    
    func read(_ text: String) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode()) ?? AVSpeechSynthesisVoice(language: "en-GB")
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
            
            self.session = session
            self.synthesizer = synthesizer
        } catch {
            NSLog("Could not start text-to-speech: \(error)")
        }
    }
    
    
    func stop() {
        synthesizer?.stopSpeaking(at: AVSpeechBoundary.immediate)
        
        try? session?.setActive(false, options: .notifyOthersOnDeactivation)
    }
    
}
