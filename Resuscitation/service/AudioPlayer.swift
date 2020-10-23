import SwiftUI
import AVFoundation


class AudioPlayer {
    
    var audioPlayer : AVAudioPlayer!
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    
    func play(_ file: URL) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                DispatchQueue.main.async { // completionHandler is called on an arbitrary dispatch queue
                    self.playWithPermissionGranted(file)
                }
            }
        }
    }
    
    private func playWithPermissionGranted(_ file: URL) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: file)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        catch {
//            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
        }
    }
    
    
    func stop() {
        if isPlaying {
            audioPlayer?.stop()
        }
    }
    
}
