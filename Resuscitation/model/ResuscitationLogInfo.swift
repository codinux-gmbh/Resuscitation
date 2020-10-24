import SwiftUI


class ResuscitationLogInfo : Identifiable, Hashable {
    
    let id: String
    
    let startTime: Date
    
    
    init(_ id: String, _ startTime: Date) {
        self.id = id
        self.startTime = startTime
    }
    
    
    static func == (lhs: ResuscitationLogInfo, rhs: ResuscitationLogInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
       hasher.combine(id)
       hasher.combine(startTime)
    }
    
}
