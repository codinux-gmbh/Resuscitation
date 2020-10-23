import SwiftUI
import AVFoundation


class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private var session: AVAudioSession!
    
    private var audioPlayer: AVAudioPlayer!
    
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    private (set) var isPaused: Bool = false
    
    private (set) var didFinishPlayback: Bool = false
    
    var currentTimeSeconds: TimeInterval {
        if didFinishPlayback {
            return audioPlayer?.duration ?? 0
        }
        
        return audioPlayer?.currentTime ?? 0
    }
    
    
    func play(_ file: URL, _ result: ((Bool) -> Void)? = nil) {
        if isPaused {
            if let successful = audioPlayer?.play() {
                result?(successful)
                return
            }
        }
        
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                DispatchQueue.main.async { // completionHandler is called on an arbitrary dispatch queue
                    let successful = self.playWithPermissionGranted(file)
                    result?(successful)
                }
            }
            else {
                result?(false)
            }
        }
    }
    
    @discardableResult
    private func playWithPermissionGranted(_ file: URL) -> Bool {
        self.session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: file)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            
            return audioPlayer.play()
        }
        catch {
            NSLog("Could not play audio file \(file): \(error)")
        }
        
        return false
    }
    
    
    func pause() {
        if isPlaying {
            self.isPaused = true
            
            audioPlayer?.pause()
        }
    }
    
    func stop() {
        if isPlaying {
            audioPlayer?.stop()
            audioPlayer = nil
            
            try? session?.setActive(false, options: .notifyOthersOnDeactivation)
            session = nil
        }
    }
    
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        NSLog("Error occured during playback: \(error)")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlayback = flag

        player.stop() // otherwise audioPlayer.isPlaying still returns true!
    }
    
}
