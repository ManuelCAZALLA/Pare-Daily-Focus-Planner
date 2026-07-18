//  FamilyProfilesViewModel.swift
//  Created by Manuel Cazalla Colmenero on 17/07/2026.

import Foundation
import Combine
import SwiftUI

class FamilyProfilesViewModel: ObservableObject {
    @Published var profiles: [FamilyProfile] = []
    
    init() {
        fetchProfiles()
    }
    
    func fetchProfiles() {
        // Datos de ejemplo iniciales
        self.profiles = [
            FamilyProfile(name: "Mamá", relationship: "Madre", colorHex: "#FF2D55", avatar: "👩"),
            FamilyProfile(name: "Papá", relationship: "Padre", colorHex: "#007AFF", avatar: "👨"),
            FamilyProfile(name: "Sofía", relationship: "Hija", colorHex: "#FF9500", avatar: "👧")
        ]
    }
    
    func addProfile(_ profile: FamilyProfile) {
        profiles.append(profile)
        // Aquí añadirías la lógica para guardar en base de datos
    }
    
    func updateProfile(_ profile: FamilyProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            // Aquí guardarías los cambios
        }
    }
    
    func deleteProfile(at offsets: IndexSet) {
        profiles.remove(atOffsets: offsets)
        // Aquí guardarías los cambios tras la eliminación
    }
    
    func deleteProfile(_ profile: FamilyProfile) {
        profiles.removeAll { $0.id == profile.id }
    }
}

