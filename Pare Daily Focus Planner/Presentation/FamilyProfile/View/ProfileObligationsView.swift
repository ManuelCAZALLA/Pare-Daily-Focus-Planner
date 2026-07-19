//
//  ProfileObligationsView.swift
//  Pare Daily Focus Planner
//

import SwiftUI
import SwiftData

struct ProfileObligationsView: View {
    @Environment(\.modelContext) private var modelContext
    let profile: FamilyProfile
    
    @State private var viewModel: ObligationsViewModel?
    @State private var showEditProfileSheet = false

    var body: some View {
        Group {
            if let vm = viewModel {
                ObligationsView(profile: profile)
                    .environment(vm)
                    .navigationTitle(profile.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showEditProfileSheet = true
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    .sheet(isPresented: $showEditProfileSheet) {
                        AddFamilyProfileSheet(editingProfile: profile)
                    }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                let repo = ObligationRepository(context: modelContext)
                viewModel = ObligationsViewModel(repository: repo, familyProfile: profile)
            }
        }
    }
}
