// CountryStore.swift
import Foundation

/// País activo para los catálogos de trámites.
/// Se inicializa con la región del dispositivo y persiste la elección del usuario
/// en el App Group compartido con el widget.
@Observable
@MainActor
final class CountryStore {
    private(set) var country: TramiteCountry

    init(country: TramiteCountry? = nil) {
        self.country = country ?? TramiteCountry.current
    }

    func set(_ country: TramiteCountry) {
        guard country != self.country else { return }
        self.country = country
        TramiteCountry.persist(country)
    }
}

