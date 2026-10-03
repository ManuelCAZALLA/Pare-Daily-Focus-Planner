// CountryMenuButton.swift
import SwiftUI

/// Menú con los catálogos de trámites disponibles.
/// Cambia el país activo, que se persiste y comparten la app y el widget.
struct CountryMenuButton: View {
    let current: TramiteCountry
    var showsLabel: Bool = false
    let onSelect: (TramiteCountry) -> Void

    var body: some View {
        Menu {
            ForEach(TramiteCountry.allCases) { country in
                Button {
                    onSelect(country)
                } label: {
                    if country == current {
                        Label(country.displayName, systemImage: "checkmark")
                    } else {
                        Text("\(country.flag)  \(country.displayName)")
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(current.flag)
                if showsLabel {
                    Text(current.displayName)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .black))
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.tramiteGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.tramiteGreen.opacity(0.10), in: Capsule())
            .overlay(Capsule().strokeBorder(Color.tramiteGreen.opacity(0.25), lineWidth: 1))
        }
        .accessibilityLabel(Text("settings.country.title"))
    }
}
