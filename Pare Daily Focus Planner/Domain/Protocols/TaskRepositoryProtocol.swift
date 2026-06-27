// TaskRepositoryProtocol.swift
import Foundation

protocol TaskRepositoryProtocol {
    func tasks(for date: Date) -> [PareTask]
    func allPending() -> [PareTask]
    func save(_ task: PareTask) throws
    func delete(_ task: PareTask) throws
    func complete(_ task: PareTask) throws
}
