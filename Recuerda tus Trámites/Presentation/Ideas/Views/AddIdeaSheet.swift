// AddIdeaSheet.swift
import SwiftUI

struct AddIdeaSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(IdeasViewModel.self) private var ideasVM

    @State private var text: String = ""

    var editingIdea: TramiteIdea? = nil
    var onCreated: ((TramiteIdea) -> Void)? = nil
    var initialCategory: IdeaCategory? = nil

    @FocusState private var textFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Texto ─────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ideas.prompt")
                            .font(.headline)

                        TextField("", text: $text, axis: .vertical)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .tint(Color.tramiteGreen)
                            .focused($textFocused)
                            .lineLimit(3...6)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(hex: "#1A1A1C"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(
                                                text.isEmpty ? Color(hex: "#2A2A2C")
                                                             : Color.tramiteGreen.opacity(0.4),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }

                    // ── Categoría ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ideas.category")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color(hex: "#8E8E93"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(IdeaCategory.allCases) { category in
                                    Button {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                            selectedCategory = category
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.systemImage)
                                                .font(.system(size: 12, weight: .bold))
                                            Text(category.label)
                                                .font(.system(size: 13, weight: .semibold))
                                                .lineLimit(1)
                                        }
                                        .padding(.vertical, 9)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(
                                                    selectedCategory == category
                                                    ? Color.ideaCategory(category).opacity(0.2)
                                                    : Color(hex: "#1A1A1C")
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .strokeBorder(
                                                            selectedCategory == category
                                                            ? Color.ideaCategory(category).opacity(0.5)
                                                            : Color(hex: "#2A2A2C"),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                        .foregroundStyle(
                                            selectedCategory == category
                                            ? Color.ideaCategory(category)
                                            : Color(hex: "#8E8E93")
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // ── Eliminar (modo edición) ────────────────────────────
                    if editingIdea != nil {
                        Button(role: .destructive) {
                            if let idea = editingIdea { ideasVM.delete(idea) }
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Label(String(localized: "general.delete"), systemImage: "trash")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.red.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.red.opacity(0.2), lineWidth: 0.8)
                                    )
                            )
                            .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(Color(hex: "#0C0C0E"))
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(editingIdea == nil ? "ideas.newTitle" : "ideas.editTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#0C0C0E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("general.cancel") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingIdea == nil ? "ideas.add" : "general.save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            text.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color(hex: "#48484A")
                            : Color.tramiteGreen
                        )
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .preferredColorScheme(.dark)
        .onAppear {
            textFocused = true
            if let idea = editingIdea {
                text = idea.text
                selectedCategory = idea.category
            } else if let initialCategory {
                selectedCategory = initialCategory
            }
        }
    }

    @State private var selectedCategory: IdeaCategory = .idea

    private func save() {
        if let idea = editingIdea {
            ideasVM.update(idea, text: text, category: selectedCategory)
        } else {
            let created = ideasVM.add(text: text, category: selectedCategory)
            if let created, let onCreated {
                onCreated(created)
            }
        }
        dismiss()
    }
}