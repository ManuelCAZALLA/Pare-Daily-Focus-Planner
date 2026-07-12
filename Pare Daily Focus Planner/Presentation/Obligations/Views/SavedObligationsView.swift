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
                        "Aún no hay trámites guardados",
                        systemImage: "tray",
                        description: Text("Registra un trámite para consultarlo y editarlo desde aquí.")
                    )
                } else {
                    List {
                        ForEach(obligationsVM.savedObligations, id: \.id) { obligation in
                            if let template = template(for: obligation) {
                                Button {
                                    selectedTemplate = template
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
                    Button("Cerrar") { dismiss() }
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
                Text(template.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)

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
            return "Vence el \(expiryDate.formatted(date: .abbreviated, time: .omitted))"
        }
        if let holderName = obligation.holderName {
            return holderName
        }
        return template.category.title
    }
}
