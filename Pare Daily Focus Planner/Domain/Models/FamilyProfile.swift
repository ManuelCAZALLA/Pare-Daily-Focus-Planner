//
//  FamilyProfile.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 17/07/2026.
//

import Foundation
import SwiftData

@Model
class FamilyProfile: Identifiable {
    var id: UUID = UUID()
    var name: String
    var relationship: String
    var colorHex: String
    var avatar: String // Almacenará un Emoji o identificador de icono
    
    @Relationship(deleteRule: .cascade)
    var obligations: [LifeObligation]?

    init(id: UUID = UUID(), name: String, relationship: String, colorHex: String, avatar: String) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.colorHex = colorHex
        self.avatar = avatar
    }
}
