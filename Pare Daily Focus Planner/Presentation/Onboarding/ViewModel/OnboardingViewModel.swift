import Foundation
import SwiftUI
import UserNotifications

@Observable
@MainActor
class OnboardingViewModel {
    var currentStep: Int = 0
    var hasRequestedNotifications = false
    
    let totalSteps = 4
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.hasRequestedNotifications = true
                completion(granted)
            }
        }
    }
}
