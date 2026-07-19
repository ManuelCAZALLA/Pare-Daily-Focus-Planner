//
//  FamilyProfileView.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 17/07/2026.
//

import SwiftUI
import SwiftData

struct FamilyProfilesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyProfile.name) private var profiles: [FamilyProfile]
    
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                if profiles.isEmpty {
                    ContentUnavailableView(
                        "No hay perfiles",
                        systemImage: "person.2.badge.gearshape",
                        description: Text("Añade miembros de tu familia para organizar mejor las obligaciones y trámites.")
                    )
                } else {
                    Section {
                        ForEach(profiles) { profile in
                            NavigationLink {
                                ProfileObligationsView(profile: profile)
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
                                }
                            }
                        }
                        .onDelete(perform: deleteProfiles)
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
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddFamilyProfileSheet()
            }
        }
    }
    
    private func deleteProfiles(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(profiles[index])
        }
    }
}
