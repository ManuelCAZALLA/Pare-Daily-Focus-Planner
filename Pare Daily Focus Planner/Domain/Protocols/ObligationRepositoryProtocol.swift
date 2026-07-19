// ObligationRepositoryProtocol.swift
import Foundation

protocol ObligationRepositoryProtocol {
    func all(forProfileID profileID: UUID?) -> [LifeObligation]
    func obligation(forTemplateID templateID: String, profileID: UUID?) -> LifeObligation?
    func save(_ obligation: LifeObligation) throws
    func delete(_ obligation: LifeObligation) throws
}
