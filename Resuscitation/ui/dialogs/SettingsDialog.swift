import SwiftUI
import Combine


struct SettingsDialog: View {
    
    static private let PickerWidth = CGFloat(50)
    
    
    @Environment(\.presentationMode) var presentation
    
    
    private let presenter: Presenter
    
    private let codeSettings: CodeSettings
    
    @State private var rhythmAnalysisTimerMinutes: Int = 2

    @State private var rhythmAnalysisTimerSeconds: Int = 0
    
    @State private var showRhythmAnalysisTimerPicker = false
    
    @State private var shockTimerMinutes: Int = 2
    
    @State private var shockTimerSeconds: Int = 0
    
    @State private var showShockTimerPicker = false
    
    @State private var adrenalinTimerMinutes: Int = 3
    
    @State private var adrenalinTimerSeconds: Int = 0
    
    @State private var showAdrenalinTimerPicker = false
    
    @State private var informUserCountSecondsBeforeTimerCountDown: Int = 10
    
    @State private var showInformUserCountSecondsBeforeTimerCountDownPicker = false
    
    @State private var informUserOfTimerCountDownOptically: Bool = true
    
    @State private var informUserOfTimerCountDownWithSound: Bool = true
    
    @State private var recordAudio: Bool = false
    
    
    init(_ presenter: Presenter) {
        self.presenter = presenter
        
        codeSettings = presenter.codeSettings
        
        _rhythmAnalysisTimerMinutes = State(initialValue: Int(codeSettings.rhythmAnalysisTimerInSeconds / 60))
        _rhythmAnalysisTimerSeconds = State(initialValue: Int(codeSettings.rhythmAnalysisTimerInSeconds % 60))
        
        _shockTimerMinutes = State(initialValue: Int(codeSettings.shockTimerInSeconds / 60))
        _shockTimerSeconds = State(initialValue: Int(codeSettings.shockTimerInSeconds % 60))
        
        _adrenalinTimerMinutes = State(initialValue: Int(codeSettings.adrenalinTimerInSeconds / 60))
        _adrenalinTimerSeconds = State(initialValue: Int(codeSettings.adrenalinTimerInSeconds % 60))
        
        _informUserCountSecondsBeforeTimerCountDown = State(initialValue: Int(codeSettings.informUserCountSecondsBeforeTimerCountDown))
        _informUserOfTimerCountDownOptically = State(initialValue: codeSettings.informUserOfTimerCountDownOptically)
        _informUserOfTimerCountDownWithSound = State(initialValue: codeSettings.informUserOfTimerCountDownWithSound)
        
        _recordAudio = State(initialValue: codeSettings.recordAudio)
    }
    

    var body: some View {
        Form {
            createTimeSection("Rhythm Analysis Timer", $rhythmAnalysisTimerMinutes, $rhythmAnalysisTimerSeconds, $showRhythmAnalysisTimerPicker)
            
            createTimeSection("Shock Timer", $shockTimerMinutes, $shockTimerSeconds, $showShockTimerPicker)
            
            createTimeSection("Adrenalin Timer", $adrenalinTimerMinutes, $adrenalinTimerSeconds, $showAdrenalinTimerPicker)
            
            Section {
                HStack {
                    Text("Warning before timer countdown ends")
                    
                    Spacer()
                    
                    Text("\(informUserCountSecondsBeforeTimerCountDown)")
                        .foregroundColor(.secondaryLabel)
                }
                .makeBackgroundTapable()
                .onTapGesture {
                    showInformUserCountSecondsBeforeTimerCountDownPicker.toggle()
                }
                
                if showInformUserCountSecondsBeforeTimerCountDownPicker {
                    HStack {
                        Spacer()
                        
                        Picker("", selection: $informUserCountSecondsBeforeTimerCountDown) {
                            ForEach((0...180), id: \.self) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                        Spacer()
                    }
                }
                
                Toggle("Inform optically", isOn: $informUserOfTimerCountDownOptically)
                
                Toggle("Inform with sound", isOn: $informUserOfTimerCountDownWithSound)
            }
            
            Section {
                Toggle("Record audio", isOn: $recordAudio)
            }
        }
        .fixKeyboardCoversLowerPart()
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: Button("Save", action: self.saveSettings))
    }
    
    
    private func createTimeSection(_ title: LocalizedStringKey, _ timerMinutes: Binding<Int>, _ timerSeconds: Binding<Int>, _ showPicker: Binding<Bool>) -> some View {
        return Section {
            HStack {
                Text(title)
                
                Spacer()
                
                Text(String(format: "%02d:%02d", timerMinutes.wrappedValue, timerSeconds.wrappedValue))
                    .foregroundColor(.secondaryLabel)
            }
            .makeBackgroundTapable()
            .onTapGesture {
                showPicker.wrappedValue.toggle()
            }
            
            if showPicker.wrappedValue {
                HStack {
                    Spacer()
                    
                    Picker(selection: timerMinutes, label: EmptyView()) {
                        ForEach((0...10), id: \.self) { second in
                            Text("\(second)").tag(second)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: Self.PickerWidth)
                    .clipped()
                    
                    Picker(selection: timerSeconds, label: EmptyView()) {
                        ForEach((0...59), id: \.self) { second in
                            Text("\(second)").tag(second)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: Self.PickerWidth)
                    .clipped()
                    
                    Spacer()
                }
            }
        }
    }
    
    
    private func saveSettings() {
        codeSettings.rhythmAnalysisTimerInSeconds = Int32(rhythmAnalysisTimerMinutes * 60 + rhythmAnalysisTimerSeconds)
        codeSettings.shockTimerInSeconds = Int32(shockTimerMinutes * 60 + shockTimerSeconds)
        codeSettings.adrenalinTimerInSeconds = Int32(adrenalinTimerMinutes * 60 + adrenalinTimerSeconds)
        
        codeSettings.informUserCountSecondsBeforeTimerCountDown = Int32(informUserCountSecondsBeforeTimerCountDown)
        codeSettings.informUserOfTimerCountDownOptically = informUserOfTimerCountDownOptically
        codeSettings.informUserOfTimerCountDownWithSound = informUserOfTimerCountDownWithSound
        
        codeSettings.recordAudio = recordAudio
        
        presenter.saveCodeSettings(codeSettings)
        
        presentation.wrappedValue.dismiss()
    }

}


struct SettingsDialog_Previews: PreviewProvider {

    static var previews: some View {
        SettingsDialog(Presenter(ResuscitationPersistence()))
    }

}
