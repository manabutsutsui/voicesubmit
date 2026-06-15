import AppTrackingTransparency
import FirebaseCore
import GoogleMobileAds
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct VoiceSubmitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    init() {
        MobileAds.shared.start { _ in
            Task { @MainActor in
                await AppOpenAdManager.shared.loadAdIfNeeded()
            }
        }
    }

    private func requestAppTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("App Tracking Transparency: authorized")
                case .denied:
                    print("App Tracking Transparency: denied")
                case .restricted:
                    print("App Tracking Transparency: restricted")
                case .notDetermined:
                    print("App Tracking Transparency: not determined")
                @unknown default:
                    print("App Tracking Transparency: unknown status")
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestAppTrackingAuthorization()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            AppOpenAdManager.shared.showAdIfAvailable()
        }
    }
}
