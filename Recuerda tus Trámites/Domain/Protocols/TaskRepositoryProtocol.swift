// TaskRepositoryProtocol.swift
import Foundation

protocol TaskRepositoryProtocol {
    func tasks(for date: Date) -> [TramiteTask]
    func allPending() -> [TramiteTask]
    func save(_ task: TramiteTask) throws
    func delete(_ task: TramiteTask) throws
    func complete(_ task: TramiteTask) throws
}
