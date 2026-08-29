// IdeasView.swift
import SwiftUI
import SwiftData

struct IdeasView: View {

    @Environment(IdeasViewModel.self) private var ideasVM

    @State private var showAddSheet = false
    @State private var editingIdea: TramiteIdea? = nil
    @State private var convertingToTaskIdea: TramiteIdea? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    categoryStrip
                    corkboard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }

            TramiteFAB {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showAddSheet = true
            }
            .padding(.trailing, 20)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showAddSheet) {
            AddIdeaSheet(initialCategory: ideasVM.selectedCategory)
                .environment(ideasVM)
                .presentationCornerRadius(28)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $editingIdea) { idea in
            AddIdeaSheet(editingIdea: idea)
                .environment(ideasVM)
                .presentationCornerRadius(28)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $convertingToTaskIdea) { idea in
            AddTaskSheet(initialTitle: idea.text, onCreated: {
                ideasVM.delete(idea)
            })
            .preferredColorScheme(.dark)
        }
        .onAppear { ideasVM.load() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ideas.title")
                .font(.largeTitle.weight(.heavy))
                .fontDesign(.rounded)

            Text("ideas.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Category strip

    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(category: nil, label: String(localized: "ideas.all"), icon: "square.grid.2x2.fill")

                ForEach(IdeaCategory.allCases) { category in
                    categoryChip(category: category, label: category.label, icon: category.systemImage)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func categoryChip(category: IdeaCategory?, label: String, icon: String) -> some View {
        let isSelected = ideasVM.selectedCategory == category
        let tint = category.map { Color.ideaCategory($0) } ?? Color.tramiteGreen

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                ideasVM.selectedCategory = isSelected ? nil : category
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.18) : Color(hex: "#1A1A1C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(isSelected ? tint.opacity(0.5) : Color(hex: "#2A2A2C"), lineWidth: 1)
                    )
            )
            .foregroundStyle(isSelected ? tint : Color(hex: "#8E8E93"))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Corkboard (muro)

    @ViewBuilder
    private var corkboard: some View {
        let ideas = ideasVM.displayedIdeas

        if ideas.isEmpty {
            EmptyStateView(
                systemImage: "lightbulb",
                title: "ideas.empty.title",
                message: "ideas.empty.message",
                actionTitle: "ideas.add",
                action: { showAddSheet = true }
            )
            .padding(.top, 40)
        } else {
            masonryLayout(ideas)
        }
    }

    // MARK: - Masonry (dos columnas de alturas libres)

    private func masonryLayout(_ ideas: [TramiteIdea]) -> some View {
        GeometryReader { proxy in
            let columnWidth = (proxy.size.width - 12) / 2
            let columns = distributeColumns(ideas)

            HStack(alignment: .top, spacing: 12) {
                ForEach(0..<2, id: \.self) { index in
                    VStack(spacing: 12) {
                        ForEach(columns[index]) { idea in
                            IdeaPostItCard(
                                idea: idea,
                                onEdit: { editingIdea = idea },
                                onTogglePin: { ideasVM.togglePin(idea) },
                                onConvertToTask: { convertingToTaskIdea = idea },
                                onDelete: { delete(idea) }
                            )
                            .frame(width: columnWidth)
                        }
                    }
                }
            }
        }
        .frame(minHeight: 200)
    }

    private func distributeColumns(_ ideas: [TramiteIdea]) -> [[TramiteIdea]] {
        // Reparte alternando para que ninguna columna quede mucho más larga
        var columns: [[TramiteIdea]] = [[], []]
        var heights: [CGFloat] = [0, 0]
        for idea in ideas {
            let target = heights[0] <= heights[1] ? 0 : 1
            columns[target].append(idea)
            heights[target] += estimatedHeight(for: idea)
        }
        return columns
    }

    private func estimatedHeight(for idea: TramiteIdea) -> CGFloat {
        let lines = max(1, Int(ceil(Double(idea.text.count) / 34.0)))
        return CGFloat(96 + (lines - 1) * 12)
    }

    // MARK: - Actions

    private func delete(_ idea: TramiteIdea) {
        ideasVM.delete(idea)
    }
}

// MARK: - Preview

private struct MockIdeaRepository: IdeaRepositoryProtocol {
    func all() -> [TramiteIdea] { [] }
    func save(_ idea: TramiteIdea) throws {}
    func delete(_ idea: TramiteIdea) throws {}
}

#Preview("Vacío") {
    IdeasView()
        .environment(IdeasViewModel(repository: MockIdeaRepository()))
        .preferredColorScheme(.dark)
}

#Preview("Con ideas") {
    let context = TramiteModelContainer.preview.mainContext
    let vm = IdeasViewModel(repository: IdeaRepository(context: context))

    func make(_ text: String, _ category: IdeaCategory, pinned: Bool = false) -> TramiteIdea {
        let idea = TramiteIdea(text: text, category: category)
        idea.isPinned = pinned
        context.insert(idea)
        return idea
    }

    make("Renovar el DNI antes de que caduque", .tramite, pinned: true)
    make("Cambiar la cerradura del trastero", .casa)
    make("Llamar a mamá el viernes", .familia)
    make("Probar el nuevo café del barrio", .otro)
    make("Buscar seguro de hogar más barato", .tramite)
    make("Regalo de cumpleaños de Lucía", .familia)
    vm.load()

    return IdeasView()
        .environment(vm)
        .modelContainer(TramiteModelContainer.preview)
        .preferredColorScheme(.dark)
}