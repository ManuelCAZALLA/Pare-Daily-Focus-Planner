//
//  AddFamilyProfieSheet.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 17/07/2026.
//

import SwiftUI

struct AddFamilyProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FamilyProfilesViewModel
    var editingProfile: FamilyProfile?
    
    // MARK: - Estados
    @State private var name: String = ""
    @State private var relationship: String = ""
    @State private var selectedAvatar: String = "👩"
    @State private var selectedColorHex: String = "#007AFF"
    
    // Opciones predefinidas para facilitar la selección rápida
    let avatars = ["👩", "👨", "👧", "👦", "👶", "👵", "👴", "🐱", "🐶", "🏡"]
    let colorPalette = ["#FF2D55", "#FF9500", "#FFCC00", "#4CD964", "#5AC8FA", "#007AFF", "#5856D6", "#8E8E93"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $name)
                        .autocorrectionDisabled()
                    
                    TextField("Parentesco (ej. Madre, Hijo)", text: $relationship)
                } header: {
                    Text("Detalles básicos")
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(avatars, id: \.self) { avatar in
                                Text(avatar)
                                    .font(.system(size: 28))
                                    .frame(width: 50, height: 50)
                                    .background(selectedAvatar == avatar ? Color(hex: selectedColorHex).opacity(0.2) : Color(.systemGroupedBackground))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedAvatar == avatar ? Color(hex: selectedColorHex) : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedAvatar = avatar
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Selecciona un Avatar")
                }
                
                Section {
                    HStack(spacing: 14) {
                        ForEach(colorPalette, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColorHex == hex ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Color Identificador")
                }
                
                if editingProfile != nil {
                    Section {
                        Button(role: .destructive) {
                            if let profile = editingProfile {
                                viewModel.deleteProfile(profile)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Eliminar Perfil")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(editingProfile == nil ? "Nuevo Perfil" : "Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let profile = editingProfile {
                    name = profile.name
                    relationship = profile.relationship
                    selectedAvatar = profile.avatar
                    selectedColorHex = profile.colorHex
                }
            }
        }
    }
    
    private func save() {
        if let profile = editingProfile {
            var updated = profile
            updated.name = name
            updated.relationship = relationship
            updated.avatar = selectedAvatar
            updated.colorHex = selectedColorHex
            viewModel.updateProfile(updated)
        } else {
            let newProfile = FamilyProfile(
                name: name,
                relationship: relationship,
                colorHex: selectedColorHex,
                avatar: selectedAvatar
            )
            viewModel.addProfile(newProfile)
        }
        dismiss()
    }
}
