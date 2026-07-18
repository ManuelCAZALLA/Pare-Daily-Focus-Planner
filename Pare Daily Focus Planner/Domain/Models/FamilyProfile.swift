//
//  FamilyProfile.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 17/07/2026.
//

import Foundation

struct FamilyProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var relationship: String
    var colorHex: String
    var avatar: String // Almacenará un Emoji o identificador de icono

    init(id: UUID = UUID(), name: String, relationship: String, colorHex: String, avatar: String) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.colorHex = colorHex
        self.avatar = avatar
    }
}
