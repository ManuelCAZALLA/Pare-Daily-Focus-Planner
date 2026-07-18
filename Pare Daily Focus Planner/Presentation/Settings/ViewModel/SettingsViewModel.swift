import SwiftUI
import StoreKit

@Observable
final class SettingsViewModel {
    
    // Versión de la app
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    // Enviar Email
    func openEmail() {
        let emailAddress = "hola@pareplanner.com" // Reemplaza con tu email real
        let subject = "Soporte Pare Daily Focus Planner".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(emailAddress)?subject=\(subject)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // Abrir Página Web
    func openWebsite() {
        if let url = URL(string: "https://www.tu-pagina-web.com") { // Reemplaza con tu web
            UIApplication.shared.open(url)
        }
    }
    
    // Política de Privacidad
    func openPrivacyPolicy() {
        if let url = URL(string: "https://www.tu-pagina-web.com/privacidad") {
            UIApplication.shared.open(url)
        }
    }
    
    // Términos de Uso
    func openTermsOfUse() {
        if let url = URL(string: "https://www.tu-pagina-web.com/terminos") {
            UIApplication.shared.open(url)
        }
    }
    
    // Valorar la App en la App Store
    func rateApp() {
        // Reemplaza "TU_APP_ID" con el ID real de tu app en App Store Connect
        let appId = "TU_APP_ID"
        if let url = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}
