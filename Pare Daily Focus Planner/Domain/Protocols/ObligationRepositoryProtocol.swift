// ObligationRepositoryProtocol.swift
import Foundation

protocol ObligationRepositoryProtocol {
    func all() -> [LifeObligation]
    func obligation(forTemplateID templateID: String) -> LifeObligation?
    func save(_ obligation: LifeObligation) throws
    func delete(_ obligation: LifeObligation) throws
}
