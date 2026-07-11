// ObligationsView.swift
import SwiftUI

struct ObligationsView: View {
    @Environment(ObligationsViewModel.self) private var obligationsVM
    @State private var showAddSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    featuresStrip
                    categoriesSection
                    templatesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }

            PareFAB { showAddSheet = true }
                .padding(.trailing, 20)
                .padding(.bottom, 32)
        }
        .sheet(isPresented: $showAddSheet) {
            addPlaceholderSheet
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trámites")
                .font(.largeTitle.weight(.heavy))
                .fontDesign(.rounded)

            Text("El asistente de los trámites que siempre se olvidan")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Adaptado a España")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.pareGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.pareGreen.opacity(0.12), in: Capsule())
        }
    }

    private var featuresStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                featureChip("Contexto inteligente", icon: "brain.head.profile")
                featureChip("Plazo de acción", icon: "calendar.badge.clock")
                featureChip("Avisos escalonados", icon: "bell.badge")
                featureChip("Checklist del trámite", icon: "checklist")
                featureChip("Perfiles familiares", icon: "person.3")
            }
        }
    }

    private func featureChip(_ title: LocalizedStringKey, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "#1A1A1C"), in: Capsule())
            .overlay(Capsule().strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1))
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categorías vitales")
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(obligationsVM.categories) { category in
                    CategoryCard(
                        category: category,
                        isSelected: obligationsVM.selectedCategory == category
                    ) {
                        if obligationsVM.selectedCategory == category {
                            obligationsVM.selectCategory(nil)
                        } else {
                            obligationsVM.selectCategory(category)
                        }
                    }
                }
            }
        }
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(obligationsVM.selectedCategory?.title ?? String(localized: "Todos los trámites"))
                    .font(.title3.weight(.bold))
                    .fontDesign(.rounded)
                Spacer()
            }

            if obligationsVM.filteredTemplates.isEmpty {
                EmptyStateView.noObligations { showAddSheet = true }
            } else {
                ForEach(obligationsVM.filteredTemplates) { template in
                    ObligationTemplateRow(
                        template: template,
                        context: obligationsVM.smartContext(for: template)
                    )
                }
            }
        }
    }

    private var addPlaceholderSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.pareGreen)
                Text("Añadir trámite")
                    .font(.title2.weight(.bold))
                Text("Próximamente podrás registrar fechas, avisos y checklists personalizados.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#0C0C0E"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { showAddSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct CategoryCard: View {
    let category: LifeAdminCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: category.systemImage)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pareGreen : .secondary)

                Text(category.title)
                    .font(.subheadline.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Text("\(category.items.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? Color.pareGreen : Color(hex: "#2A2A2C"), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ObligationTemplateRow: View {
    let template: ObligationTemplate
    let context: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.title)
                    .font(.body.weight(.semibold))
                    .fontDesign(.rounded)
                Spacer()
                Text("Actúa ahora")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.pareGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pareGreen.opacity(0.12), in: Capsule())
            }

            Text(context)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
        )
    }
}

private struct MockObligationRepository: ObligationRepositoryProtocol {
    func all() -> [LifeObligation] { [] }
    func obligation(forTemplateID templateID: String) -> LifeObligation? { nil }
    func save(_ obligation: LifeObligation) throws {}
    func delete(_ obligation: LifeObligation) throws {}
}

#Preview {
    ObligationsView()
        .environment(ObligationsViewModel(repository: MockObligationRepository()))
        .preferredColorScheme(.dark)
}
