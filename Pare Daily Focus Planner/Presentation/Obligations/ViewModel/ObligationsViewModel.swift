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
    private let notificationService: NotificationService?

    var categories: [LifeAdminCategory] = LifeAdminCategory.allCases
    var selectedCategory: LifeAdminCategory?
    var familyProfile: FamilyProfile?
    var searchText: String = ""
    var savedObligations: [LifeObligation] = []

    init(
        repository: ObligationRepositoryProtocol,
        notificationService: NotificationService? = nil,
        familyProfile: FamilyProfile? = nil
    ) {
        self.repository = repository
        self.notificationService = notificationService
        self.familyProfile = familyProfile
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
        savedObligations = repository.all(forProfileID: familyProfile?.id)
    }

    func obligation(for template: ObligationTemplate) -> LifeObligation? {
        repository.obligation(forTemplateID: template.id, profileID: familyProfile?.id)
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
        alertOffset: ObligationAlertOffset?,
        notes: String,
        documentsNeeded: String
    ) throws {
        let obligation = existing ?? LifeObligation(templateID: template.id)
        obligation.familyProfile = familyProfile
        notificationService?.cancel(for: obligation)
        obligation.holderName = holderName.nilIfEmpty
        obligation.expiryDate = expiryDate
        obligation.actionStartDate = actionStartDate
        obligation.alertOffset = expiryDate == nil ? nil : alertOffset
        obligation.notes = notes.nilIfEmpty
        obligation.documentsNeeded = documentsNeeded.nilIfEmpty
        try repository.save(obligation)
        notificationService?.schedule(for: obligation, title: template.title)
        try repository.save(obligation)
        load()
    }

    func delete(_ obligation: LifeObligation) throws {
        notificationService?.cancel(for: obligation)
        try repository.delete(obligation)
        load()
    }

    func requestNotificationPermission() async {
        await notificationService?.requestPermission()
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
