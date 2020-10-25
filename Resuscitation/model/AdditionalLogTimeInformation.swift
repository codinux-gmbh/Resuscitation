import SwiftUI


enum AdditionalLogTimeInformation : String, CaseIterable, Identifiable {
    
    case TimeSinceStart
    
    case TimeSinceLastSameAction
    
    case ComparisonToOptimalTime
    
    case Off
    
    
    var id: AdditionalLogTimeInformation { self }
    
}
