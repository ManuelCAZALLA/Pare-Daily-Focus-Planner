// ObligationsView.swift
import SwiftUI

struct ObligationsView: View {
    @Environment(ObligationsViewModel.self) private var obligationsVM
    @State private var showAddEditSheet = false
    @State private var showSavedObligations = false
    @State private var selectedTemplate: ObligationTemplate? = nil

    var body: some View {
        @Bindable var vm = obligationsVM
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    featuresStrip
                    searchBar
                    categoriesSection
                    templatesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }

            PareFAB {
                selectedTemplate = nil
                showAddEditSheet = true
            }
            .padding(.trailing, 20)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showAddEditSheet) {
            Group {
                if let template = selectedTemplate {
                    AddObligationSheet(
                        template: template,
                        editingObligation: obligationsVM.obligation(for: template)
                    )
                } else {
                    NavigationStack {
                        SelectTemplateSheet { template in
                            selectedTemplate = template
                        }
                    }
                }
            }
            .environment(obligationsVM)
            .presentationCornerRadius(28)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSavedObligations) {
            SavedObligationsView()
                .environment(obligationsVM)
                .preferredColorScheme(.dark)
        }
        .onChange(of: showAddEditSheet) { _, newValue in
            if !newValue {
                selectedTemplate = nil
            }
        }
        .onAppear {
            obligationsVM.load()
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

            Button {
                showSavedObligations = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "tray.full.fill")
                    Text(obligationsVM.savedObligations.isEmpty
                         ? "Ver trámites guardados"
                         : "Ver trámites guardados (\(obligationsVM.savedObligations.count))")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.pareGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.pareGreen.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.pareGreen.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
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

    private var searchBar: some View {
        @Bindable var vm = obligationsVM
        return HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Buscar trámite...", text: $vm.searchText)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)

            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
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
                EmptyStateView.noObligations {
                    selectedTemplate = nil
                    showAddEditSheet = true
                }
            } else {
                ForEach(obligationsVM.filteredTemplates) { template in
                    Button {
                        selectedTemplate = template
                        showAddEditSheet = true
                    } label: {
                        ObligationTemplateRow(
                            template: template,
                            context: obligationsVM.smartContext(for: template),
                            status: obligationsVM.statusLabel(for: template),
                            isRegistered: obligationsVM.isRegistered(template)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
    let status: String
    let isRegistered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.title)
                    .font(.body.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                Spacer()
                Text(status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isRegistered ? Color.pareGreen : Color(hex: "#8E8E93"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isRegistered ? Color.pareGreen.opacity(0.12) : Color(hex: "#2A2A2C"), in: Capsule())
            }

            Text(context)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
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
