import SwiftUI
import AVFoundation


class AudioRecorder : NSObject, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    var duration: TimeInterval {
        return audioRecorder?.currentTime ?? 0
    }
    
    
    func record(_ file: URL) {
        if let audioRecorder = audioRecorder { // resume recording
            if audioRecorder.isRecording == false {
                audioRecorder.record()
                return
            }
        }
        
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                DispatchQueue.main.async { // completionHandler is called on an arbitrary dispatch queue
                    self.recordWithPermissionGranted(file)
                }
            }
        }
    }
    
    private func recordWithPermissionGranted(_ file: URL) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: file, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            
            audioRecorder.record()
        }
        catch {
            NSLog("Could not start recording: \(error)")
        }
    }
    
    
    func pause() {
        if isRecording {
            audioRecorder?.pause()
        }
    }
    
    func stop() {
        if isRecording {
            audioRecorder.stop()
            audioRecorder = nil // TODO: remove if should be able to resume audio recording
        }
    }
    
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        NSLog("Error occured during recording: \(error)")
    }
    
}
