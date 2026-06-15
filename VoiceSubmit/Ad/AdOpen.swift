import Foundation
import GoogleMobileAds
import UIKit

final class AppOpenAdManager: NSObject {
    static let shared = AppOpenAdManager()

    /// The app open ad.
    private var appOpenAd: AppOpenAd?

    /// Keeps track of if an app open ad is loading.
    private var isLoadingAd = false

    /// Keeps track of if an app open ad is showing.
    private var isShowingAd = false

    /// Keeps track of the time when an app open ad was loaded to discard expired ad.
    private var loadTime: Date?

    /// AdUnitID（`Secrets.plist` の `AdMobAppOpenAdUnitID`）の取得関数
    private var adUnitIDProvider: () -> String = {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let adUnitID = dict["AdOpenId"] as? String,
              !adUnitID.isEmpty
        else {
            print("警告: AdOpenIdが見つかりません")
            return ""
        }
        return adUnitID
    }

    /// For more interval details, see https://support.google.com/admob/answer/9341964
    private let timeoutInterval: TimeInterval = 4 * 3_600

    private override init() {
        super.init()
    }

    /// AdUnitID を外部から注入したい場合に使用（テストIDへの切り替えなど）
    func setAdUnitIDProvider(_ provider: @escaping () -> String) {
        adUnitIDProvider = provider
    }

    private func wasLoadTimeLessThanTimeoutAgo(timeoutInterval: TimeInterval) -> Bool {
        if let loadTime {
            return Date().timeIntervalSince(loadTime) < timeoutInterval
        }
        return false
    }

    private func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil && wasLoadTimeLessThanTimeoutAgo(timeoutInterval: timeoutInterval)
    }

    /// 事前ロード（呼び出し側で `Task { await loadAdIfNeeded() }` の形で利用）
    @MainActor
    func loadAdIfNeeded() async {
        let adUnitID = adUnitIDProvider()
        guard !adUnitID.isEmpty else { return }

        // Do not load ad if there is an unused ad or one is already loading.
        if isLoadingAd || isAdAvailable() { return }

        isLoadingAd = true
        defer { isLoadingAd = false }

        do {
            appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            appOpenAd?.fullScreenContentDelegate = self
            loadTime = Date()
        } catch {
            print("App open ad failed to load with error: \(error.localizedDescription)")
            appOpenAd = nil
            loadTime = nil
        }
    }

    /// 表示できる状態なら表示する。未ロードならロードだけ開始して終了する（UX優先）
    @MainActor
    func showAdIfAvailable() {
        // If the app open ad is already showing, do not show the ad again.
        if isShowingAd {
            return
        }

        // If the app open ad is not available yet, load a new ad.
        if !isAdAvailable() {
            Task { await loadAdIfNeeded() }
            return
        }

        guard let appOpenAd else { return }
        appOpenAd.present(from: nil)
        isShowingAd = true
    }
}

extension AppOpenAdManager: FullScreenContentDelegate {
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("App open ad recorded an impression.")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("App open ad recorded a click.")
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("App open ad will be presented.")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("App open ad will be dismissed.")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("App open ad was dismissed.")
        appOpenAd = nil
        isShowingAd = false

        Task { await loadAdIfNeeded() }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("App open ad failed to present with error: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false

        Task { await loadAdIfNeeded() }
    }
}
