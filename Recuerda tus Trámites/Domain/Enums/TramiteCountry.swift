// TramiteCountry.swift
import Foundation

enum TramiteCountry: String, CaseIterable, Identifiable, Codable {
    case spain = "ES"
    case mexico = "MX"
    case colombia = "CO"
    case argentina = "AR"
    case chile = "CL"
    case peru = "PE"
    case ecuador = "EC"
    case unitedKingdom = "GB"
    case unitedStates = "US"
    case france = "FR"
    case germany = "DE"
    case italy = "IT"
    case portugal = "PT"
    case international = "XX"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .spain:         return String(localized: "España")
        case .mexico:        return String(localized: "México")
        case .colombia:      return String(localized: "Colombia")
        case .argentina:     return String(localized: "Argentina")
        case .chile:         return String(localized: "Chile")
        case .peru:          return String(localized: "Perú")
        case .ecuador:       return String(localized: "Ecuador")
        case .unitedKingdom: return String(localized: "Reino Unido")
        case .unitedStates:  return String(localized: "Estados Unidos")
        case .france:        return String(localized: "Francia")
        case .germany:       return String(localized: "Alemania")
        case .italy:         return String(localized: "Italia")
        case .portugal:      return String(localized: "Portugal")
        case .international: return String(localized: "Internacional")
        }
    }

    var flag: String {
        self == .international ? "🌍" : flagEmoji
    }

    /// Emoji de bandera a partir del código ISO. Los sistemas sin bandera
    /// (regiones ISO, por ejemplo "419") caen en los emojis de país habituales.
    private var flagEmoji: String {
        let base: UInt32 = 0x1F1E6
        var emoji = ""
        for scalar in rawValue.unicodeScalars {
            guard let value = UnicodeScalar(base + scalar.value - 65) else { return "🌍" }
            emoji.unicodeScalars.append(value)
        }
        return emoji
    }

    // MARK: - Persistencia

    static let storageKey = "selectedCountry"
    static let appGroupID = "group.com.manuelcazalla.recuerdatustramites"

    /// País elegido por el usuario. Si nunca se ha elegido, se detecta desde la región del dispositivo.
    /// Comparte App Group con el widget para que ambos pinten los mismos títulos.
    static var current: TramiteCountry {
        if let raw = sharedDefaults.string(forKey: storageKey),
           let stored = TramiteCountry(rawValue: raw) {
            return stored
        }
        return detected
    }

    static func persist(_ country: TramiteCountry) {
        sharedDefaults.set(country.rawValue, forKey: storageKey)
    }

    private static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    // MARK: - Detección

    /// Región del dispositivo mapeada a un catálogo concreto.
    /// Si la región no tiene catálogo propio se usa el idioma como pista.
    static var detected: TramiteCountry {
        let locale = Locale.current
        if let region = locale.region?.identifier.uppercased(),
           let match = TramiteCountry(regionCode: region) {
            return match
        }
        let language = locale.language.languageCode?.identifier.lowercased() ?? "es"
        return TramiteCountry(languageCode: language) ?? .international
    }

    init?(regionCode: String) {
        switch regionCode.uppercased() {
        case "ES": self = .spain
        case "MX": self = .mexico
        case "CO": self = .colombia
        case "AR": self = .argentina
        case "CL": self = .chile
        case "PE": self = .peru
        case "EC": self = .ecuador
        case "GB", "UK": self = .unitedKingdom
        case "US": self = .unitedStates
        case "FR": self = .france
        case "DE": self = .germany
        case "IT": self = .italy
        case "PT": self = .portugal
        case "419": self = .international
        default: return nil
        }
    }

    init?(languageCode: String) {
        switch languageCode.lowercased() {
        case "es": self = .spain
        case "fr": self = .france
        case "de": self = .germany
        case "it": self = .italy
        case "pt": self = .portugal
        case "en": self = .unitedKingdom
        default: return nil
        }
    }
}
