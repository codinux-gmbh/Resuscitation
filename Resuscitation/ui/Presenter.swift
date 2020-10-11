import SwiftUI


class Presenter {
    
    func preventScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func reenableScreenLock() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}
