import SwiftUI
import StoreKit

@Observable
final class SettingsViewModel {

    // Versión de la app
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var emailURL: URL? {
        let emailAddress = "soportecazalla@gmail.com"
        let subject = String(localized: "Soporte Recuerda tus Trámites").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:\(emailAddress)?subject=\(subject)")
    }

    var websiteURL: URL? {
        URL(string: "https://manuelcazalla.github.io/Pare-Web/")
    }

    var privacyPolicyURL: URL? {
        URL(string: "https://manuelcazalla.github.io/pare-privacidad.html/")
    }

    var termsOfUseURL: URL? {
        URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    }

    var rateAppURL: URL? {
        guard let appId = AppStoreConstants.appStoreID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review")
    }
}
