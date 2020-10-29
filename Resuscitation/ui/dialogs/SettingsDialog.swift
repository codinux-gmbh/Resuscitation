import SwiftUI
import Combine


struct SettingsDialog: View {
    
    
    @Environment(\.presentationMode) var presentation
    
    
    private let presenter: Presenter
    
    private let codeSettings: CodeSettings

    @State private var rhythmAnalysisTimer: Date = Date()
    
    @State private var shockTimer: Date = Date()
    
    @State private var adrenalinTimer: Date = Date()
    
    @State private var informUserCountSecondsBeforeTimerCountDown: Int = 10
    
    @State private var showInformUserCountSecondsBeforeTimerCountDownPicker = false
    
    @State private var informUserOfTimerCountDownOptically: Bool = true
    
    @State private var informUserOfTimerCountDownWithSound: Bool = true
    
    @State private var recordAudio: Bool = false
    
    
    init(_ presenter: Presenter) {
        self.presenter = presenter
        
        codeSettings = presenter.codeSettings
        
        _rhythmAnalysisTimer = State(initialValue: formatSecondsAsDate(codeSettings.rhythmAnalysisTimerInSeconds))
        _shockTimer = State(initialValue: formatSecondsAsDate(codeSettings.shockTimerInSeconds))
        _adrenalinTimer = State(initialValue: formatSecondsAsDate(codeSettings.adrenalinTimerInSeconds))
        
        _informUserCountSecondsBeforeTimerCountDown = State(initialValue: Int(codeSettings.informUserCountSecondsBeforeTimerCountDown))
        _informUserOfTimerCountDownOptically = State(initialValue: codeSettings.informUserOfTimerCountDownOptically)
        _informUserOfTimerCountDownWithSound = State(initialValue: codeSettings.informUserOfTimerCountDownWithSound)
        
        _recordAudio = State(initialValue: codeSettings.recordAudio)
    }
    

    var body: some View {
        Form {
            createTimeSection("Rhythm Analysis Timer", $rhythmAnalysisTimer)
            
            createTimeSection("Shock Timer", $shockTimer)
            
            createTimeSection("Adrenalin Timer", $adrenalinTimer)
            
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
    
    
    private func createTimeSection(_ title: LocalizedStringKey, _ timer: Binding<Date>) -> some View {
        return Section {
            DatePicker(title, selection: timer, displayedComponents: .hourAndMinute)
        }
    }
    
    private func formatSecondsAsDate(_ timeInSeconds: Int32) -> Date {
        return formatSecondsAsDate(Int(timeInSeconds))
    }
    
    private func formatSecondsAsDate(_ timeInSeconds: Int) -> Date {
    // as there is no picker for minutes and seconds we misuse a DatePicker and tell him it's hours and minutes

        var components = DateComponents()
        
        components.hour = timeInSeconds / 60
        components.minute = timeInSeconds % 60
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func convertDateToTimeInSeconds(_ time: Date) -> Int32 {
        let calendar = Calendar.current
        
        let minutes = calendar.component(.hour, from: time)
        let seconds = calendar.component(.minute, from: time)
        
        return Int32(minutes * 60 + seconds)
    }
    
    
    private func saveSettings() {
        codeSettings.rhythmAnalysisTimerInSeconds = convertDateToTimeInSeconds(rhythmAnalysisTimer)
        codeSettings.shockTimerInSeconds = convertDateToTimeInSeconds(shockTimer)
        codeSettings.adrenalinTimerInSeconds = convertDateToTimeInSeconds(adrenalinTimer)
        
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
