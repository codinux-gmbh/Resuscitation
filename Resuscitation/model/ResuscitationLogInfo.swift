import SwiftUI


class ResuscitationLogInfo : Identifiable {
    
    let id: String
    
    let startTime: Date
    
    
    init(_ id: String, _ startTime: Date) {
        self.id = id
        self.startTime = startTime
    }
    
}
