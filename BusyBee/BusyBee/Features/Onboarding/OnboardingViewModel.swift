import Foundation
import Combine
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    private let locationManager: LocationManager
    
    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
    }
    
    func completeOnboarding(hasCompletedOnboarding: inout Bool) {
        locationManager.checkLocationAuthorization()
        hasCompletedOnboarding = true
    }
}
