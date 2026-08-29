// IdeaRepositoryProtocol.swift
import Foundation

protocol IdeaRepositoryProtocol {
    func all() -> [TramiteIdea]
    func save(_ idea: TramiteIdea) throws
    func delete(_ idea: TramiteIdea) throws
}