// SelectTemplateSheet.swift
import SwiftUI

struct SelectTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ObligationsViewModel.self) private var obligationsVM
    @State private var searchText = ""
    let onSelect: (ObligationTemplate) -> Void

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(LifeAdminCategory.allCases) { category in
                        let templates = filteredTemplates(for: category)
                        if !templates.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: category.systemImage)
                                        .foregroundStyle(Color.pareGreen)
                                    Text(category.title)
                                        .font(.subheadline.bold())
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 4)

                                VStack(spacing: 8) {
                                    ForEach(templates) { template in
                                        Button {
                                            onSelect(template)
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(template.title)
                                                        .font(.body.weight(.semibold))
                                                        .foregroundStyle(.white)
                                                    
                                                    if let hint = template.contextHint {
                                                        Text(hint)
                                                            .font(.caption)
                                                            .foregroundStyle(.secondary)
                                                            .multilineTextAlignment(.leading)
                                                    }
                                                }
                                                Spacer()
                                                
                                                if obligationsVM.isRegistered(template) {
                                                    Text("Registrado")
                                                        .font(.caption.weight(.semibold))
                                                        .foregroundStyle(Color.pareGreen)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.pareGreen.opacity(0.12), in: Capsule())
                                                } else {
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundStyle(Color(hex: "#48484A"))
                                                }
                                            }
                                            .padding(14)
                                            .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color(hex: "#0C0C0E").ignoresSafeArea())
        .navigationTitle("Seleccionar plantilla")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundStyle(Color(hex: "#8E8E93"))
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Buscar trámite...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
        )
    }

    private func filteredTemplates(for category: LifeAdminCategory) -> [ObligationTemplate] {
        let items = category.items
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}
