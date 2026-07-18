//
//  FamilyProfileView.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 17/07/2026.
//

import SwiftUI

struct FamilyProfilesView: View {
    @StateObject private var viewModel = FamilyProfilesViewModel()
    @State private var activeSheet: SheetType?
    
    enum SheetType: Identifiable {
        case add
        case edit(FamilyProfile)
        
        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let profile): return "edit-\(profile.id.uuidString)"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.profiles.isEmpty {
                    ContentUnavailableView(
                        "No hay perfiles",
                        systemImage: "person.2.badge.gearshape",
                        description: Text("Añade miembros de tu familia para organizar mejor las obligaciones.")
                    )
                } else {
                    Section {
                        ForEach(viewModel.profiles) { profile in
                            Button {
                                activeSheet = .edit(profile)
                            } label: {
                                HStack(spacing: 16) {
                                    // Avatar con fondo circular de su color asignado
                                    Text(profile.avatar)
                                        .font(.system(size: 24))
                                        .frame(width: 48, height: 48)
                                        .background(Color(hex: profile.colorHex).opacity(0.15))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .strokeBorder(Color(hex: profile.colorHex).opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(profile.name)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary)
                                        
                                        Text(profile.relationship)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.quaternary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: viewModel.deleteProfile)
                    } header: {
                        Text("Miembros de la familia")
                    }
                }
            }
            .navigationTitle("Perfiles Familiares")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    AddFamilyProfileSheet(viewModel: viewModel)
                case .edit(let profile):
                    AddFamilyProfileSheet(viewModel: viewModel, editingProfile: profile)
                }
            }
        }
    }
}
