import SwiftUI


class Styles {
    
    static public var DateFormat: String {
        return "yyyy-MM-dd"
    }
    
    static public var TimeFormat: String {
        return "HH:mm"
    }
    
    static public var TimeFormatWithSeconds: String {
        return "HH:mm:ss"
    }
    
    static public let LogDateFormatter = DateFormatter() // prefixed with 'Log' to avoid naming conflict with DateFormatter
    
    static public let TimeFormatter = DateFormatter()
    
    static public let TimeFormatterWithSeconds = DateFormatter()
    
    
    static func initialize() {
        LogDateFormatter.dateFormat = DateFormat
        TimeFormatter.dateFormat = TimeFormat
        TimeFormatterWithSeconds.dateFormat = TimeFormatWithSeconds
    }
    
}
