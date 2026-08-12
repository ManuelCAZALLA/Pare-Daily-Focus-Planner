import SwiftUI

struct SavedObligationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ObligationsViewModel.self) private var obligationsVM
    @State private var selectedTemplate: ObligationTemplate?

    var body: some View {
        NavigationStack {
            Group {
                if obligationsVM.savedObligations.isEmpty {
                    ContentUnavailableView(
                        "obligations.empty",
                        systemImage: "tray",
                        description: Text("Registra un trámite para consultarlo y editarlo desde aquí.")
                    )
                } else {
                    List {
                        ForEach(obligationsVM.savedObligations, id: \.id) { obligation in
                            if let template = template(for: obligation) {
                                Button {
                                    selectedTemplate = template
                                    obligationsVM.scannedDocumentData = obligation.scannedDocumentData
                                } label: {
                                    SavedObligationRow(obligation: obligation, template: template)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color(hex: "#1A1A1C"))
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(hex: "#0C0C0E").ignoresSafeArea())
            .navigationTitle("Trámites guardados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("general.close") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
            }
            .sheet(item: $selectedTemplate) { template in
                AddObligationSheet(
                    template: template,
                    editingObligation: obligationsVM.obligation(for: template)
                )
                .environment(obligationsVM)
                .preferredColorScheme(.dark)
            }
        }
        .onAppear { obligationsVM.load() }
    }

    private func template(for obligation: LifeObligation) -> ObligationTemplate? {
        ObligationTemplate.all.first { $0.id == obligation.templateID }
    }
}

private struct SavedObligationRow: View {
    let obligation: LifeObligation
    let template: ObligationTemplate

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.category.systemImage)
                .font(.title3)
                .foregroundStyle(Color.pareGreen)
                .frame(width: 34, height: 34)
                .background(Color.pareGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(template.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)

                    if obligation.scannedDocumentData != nil {
                        Image(systemName: "doc.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.pareGreen)
                    }
                }

                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: "#636366"))
        }
        .padding(.vertical, 5)
    }

    private var detailText: String {
        if let expiryDate = obligation.expiryDate {
            return String(format: String(localized: "Vence el %@"), expiryDate.formatted(date: .abbreviated, time: .omitted))
        }
        if let holderName = obligation.holderName {
            return holderName
        }
        return template.category.title
    }
}
