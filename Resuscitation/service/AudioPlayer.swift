import SwiftUI
import AVFoundation


class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
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
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        catch {
            NSLog("Could not play audio file \(file): \(error)")
        }
    }
    
    
    func stop() {
        if isPlaying {
            audioPlayer?.stop()
        }
    }
    
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        NSLog("Error occured during playback: \(error)")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish playback. successfully? \(flag)") // TODO: change UI then
    }
    
}
