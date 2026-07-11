// ObligationsViewModel.swift
import Foundation

enum ObligationUrgency: String, CaseIterable {
    case threeMonths
    case oneMonth
    case twoWeeks
    case urgent

    var label: String {
        switch self {
        case .threeMonths: return String(localized: "En 3 meses")
        case .oneMonth:      return String(localized: "En 1 mes")
        case .twoWeeks:      return String(localized: "En 2 semanas")
        case .urgent:        return String(localized: "Urgente")
        }
    }
}

@Observable
@MainActor
final class ObligationsViewModel {
    private let repository: ObligationRepositoryProtocol

    var categories: [LifeAdminCategory] = LifeAdminCategory.allCases
    var selectedCategory: LifeAdminCategory?
    var searchText: String = ""
    var savedObligations: [LifeObligation] = []

    init(repository: ObligationRepositoryProtocol) {
        self.repository = repository
    }

    var registeredTemplates: [ObligationTemplate] {
        savedObligations.compactMap { obligation in
            ObligationTemplate.all.first { $0.id == obligation.templateID }
        }
    }

    var filteredTemplates: [ObligationTemplate] {
        let base = selectedCategory?.items ?? ObligationTemplate.all
        let filtered = searchText.isEmpty
            ? base
            : base.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        return filtered
    }

    func load() {
        savedObligations = repository.all()
    }

    func obligation(for template: ObligationTemplate) -> LifeObligation? {
        repository.obligation(forTemplateID: template.id)
    }

    func selectCategory(_ category: LifeAdminCategory?) {
        selectedCategory = category
    }

    func save(
        template: ObligationTemplate,
        existing: LifeObligation?,
        holderName: String,
        expiryDate: Date?,
        actionStartDate: Date?,
        notes: String,
        location: String,
        estimatedCost: String,
        documentsNeeded: String
    ) throws {
        let obligation = existing ?? LifeObligation(templateID: template.id)
        obligation.holderName = holderName.nilIfEmpty
        obligation.expiryDate = expiryDate
        obligation.actionStartDate = actionStartDate
        obligation.notes = notes.nilIfEmpty
        obligation.location = location.nilIfEmpty
        obligation.estimatedCost = estimatedCost.nilIfEmpty
        obligation.documentsNeeded = documentsNeeded.nilIfEmpty
        try repository.save(obligation)
        load()
    }

    func delete(_ obligation: LifeObligation) throws {
        try repository.delete(obligation)
        load()
    }

    func smartContext(for template: ObligationTemplate) -> String {
        if let obligation = obligation(for: template),
           let days = obligation.daysUntilExpiry {
            if let hint = template.contextHint {
                return String(
                    format: String(localized: "Tu %@ vence en %lld días — %@. Actúa ahora."),
                    template.title,
                    days,
                    hint
                )
            }
            return String(
                format: String(localized: "Tu %@ vence en %lld días. Actúa ahora."),
                template.title,
                days
            )
        }
        return String(localized: "Toca para registrar tus datos y recibir avisos.")
    }

    func statusLabel(for template: ObligationTemplate) -> String {
        guard let obligation = obligation(for: template) else {
            return String(localized: "Toca para registrar")
        }
        if let expiryDate = obligation.expiryDate {
            return String(
                format: String(localized: "Vence el %@"),
                expiryDate.formatted(date: .abbreviated, time: .omitted)
            )
        }
        return String(localized: "Registrado")
    }

    func isRegistered(_ template: ObligationTemplate) -> Bool {
        obligation(for: template) != nil
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
