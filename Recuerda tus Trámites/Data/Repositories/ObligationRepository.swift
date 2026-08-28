// ObligationRepository.swift
import Foundation
import SwiftData

final class ObligationRepository: ObligationRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all(forProfileID profileID: UUID?) -> [LifeObligation] {
        let descriptor: FetchDescriptor<LifeObligation>
        
        // Evaluamos el opcional fuera de la macro para simplificar la expresión
        if let targetProfileID = profileID {
            descriptor = FetchDescriptor<LifeObligation>(
                predicate: #Predicate<LifeObligation> { obligation in
                    obligation.familyProfile?.id == targetProfileID
                },
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<LifeObligation>(
                predicate: #Predicate<LifeObligation> { obligation in
                    obligation.familyProfile == nil
                },
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
        }
        
        return (try? context.fetch(descriptor)) ?? []
    }

    func obligation(forTemplateID templateID: String, profileID: UUID?) -> LifeObligation? {
        let descriptor: FetchDescriptor<LifeObligation>
        
        if let targetProfileID = profileID {
            descriptor = FetchDescriptor<LifeObligation>(
                predicate: #Predicate<LifeObligation> { obligation in
                    obligation.templateID == templateID && obligation.familyProfile?.id == targetProfileID
                }
            )
        } else {
            descriptor = FetchDescriptor<LifeObligation>(
                predicate: #Predicate<LifeObligation> { obligation in
                    obligation.templateID == templateID && obligation.familyProfile == nil
                }
            )
        }
        
        return try? context.fetch(descriptor).first
    }

    func save(_ obligation: LifeObligation) throws {
        obligation.updatedAt = Date()
        if obligation.modelContext == nil {
            context.insert(obligation)
        }
        try context.save()
    }

    func delete(_ obligation: LifeObligation) throws {
        context.delete(obligation)
        try context.save()
    }
}
