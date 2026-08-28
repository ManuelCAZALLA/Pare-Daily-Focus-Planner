//
//  FamilyProfileView.swift
//  Recuerda tus Trámites
//
//  Created by Manuel Cazalla Colmenero on 17/07/2026.
//

import SwiftUI
import SwiftData
import RevenueCatUI

struct FamilyProfilesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchasesService.self) private var purchases
    @Query(sort: \FamilyProfile.name) private var profiles: [FamilyProfile]
    
    @State private var showAddSheet = false
    @State private var showPaywall = false
    
    private let maxFreeProfiles = 1
    private let maxProProfiles = 6
    
    private var canAddMore: Bool {
        if purchases.isProActive {
            return profiles.count < maxProProfiles
        }
        return profiles.count < maxFreeProfiles
    }
    
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
                    
                    if !purchases.isProActive && profiles.count >= maxFreeProfiles {
                        Section {
                            VStack(spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(Color.tramiteGreen)
                                    Text("Versión gratuita: 1 perfil máximo")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                }
                                Text("Desbloquea hasta 6 perfiles familiares con Recuerda tus Trámites Pro.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    showPaywall = true
                                } label: {
                                    Text("Desbloquear Pro")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.tramiteGreen, in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Perfiles Familiares")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .disabled(!canAddMore && !purchases.isProActive)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddFamilyProfileSheet()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    private func deleteProfiles(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(profiles[index])
        }
    }
}
