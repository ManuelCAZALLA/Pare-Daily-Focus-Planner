//
//  PomodoroViewModel.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 04/07/2026.
//

import UIKit
import Foundation
import SwiftData
import UserNotifications
import AudioToolbox

@Observable
final class PomodoroViewModel {

    // MARK: - Timer state
    var timeRemaining: Int = 25 * 60
    var totalTime: Int = 25 * 60
    var isRunning: Bool = false
    var currentSession: SessionType = .focus
    var sessionsCompleted: Int = 0   // en la ronda actual

    // MARK: - Task
    var activeTask: PareTask? = nil

    // MARK: - Config
    var focusDuration: Int = 25      // minutos
    var shortBreakDuration: Int = 5
    var longBreakDuration: Int = 15
    var sessionsPerRound: Int = 4

    // MARK: - Stats today
    var totalSessionsToday: Int = 0
    var totalFocusTimeToday: Int = 0  // segundos
    var focusStreakDays: Int = 0

    // MARK: - Private
    private var timer: Timer? = nil
    private let repository: FocusSessionRepositoryProtocol?
    private var sessionStartedAt: Date? = nil

    // MARK: - Computed
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalTime))
    }

    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var sessionLabel: String {
        switch currentSession {
        case .focus:       return String(localized: "Focus")
        case .shortBreak:  return String(localized: "Short Break")
        case .longBreak:   return String(localized: "Long Break")
        }
    }

    var sessionColor: String {
        switch currentSession {
        case .focus:       return "#22C55E"
        case .shortBreak:  return "#007AFF"
        case .longBreak:   return "#AF52DE"
        }
    }

    // MARK: - Init
    init(repository: FocusSessionRepositoryProtocol? = nil) {
        self.repository = repository
        resetTimer()
    }

    // MARK: - Controls

    func start() {
        guard !isRunning else { return }
        isRunning = true
        sessionStartedAt = Date()
        scheduleBackgroundNotification()
        startTicking()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate()
        timer = nil
        cancelBackgroundNotification()
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func skip() {
        pause()
        cancelBackgroundNotification()
        advanceSession(completed: false)
    }

    func reset() {
        pause()
        cancelBackgroundNotification()
        timeRemaining = totalTime
    }

    func selectTask(_ task: PareTask?) {
        activeTask = task
    }

    // MARK: - Config setters

    func setFocusDuration(_ minutes: Int) {
        focusDuration = minutes
        if currentSession == .focus && !isRunning {
            totalTime = minutes * 60
            timeRemaining = totalTime
        }
    }

    func setShortBreak(_ minutes: Int) {
        shortBreakDuration = minutes
        if currentSession == .shortBreak && !isRunning {
            totalTime = minutes * 60
            timeRemaining = totalTime
        }
    }

    func setLongBreak(_ minutes: Int) {
        longBreakDuration = minutes
        if currentSession == .longBreak && !isRunning {
            totalTime = minutes * 60
            timeRemaining = totalTime
        }
    }

    func setSessionsPerRound(_ count: Int) {
        sessionsPerRound = count
    }

    // MARK: - Private

    private func startTicking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.sessionFinished()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func sessionFinished() {
        pause()
        hapticSuccess()

        if currentSession == .focus {
            sessionsCompleted += 1
            totalSessionsToday += 1
            totalFocusTimeToday += focusDuration * 60
            saveSession(completed: true)
        }

        advanceSession(completed: true)
    }

    private func advanceSession(completed: Bool) {
        switch currentSession {
        case .focus:
            if sessionsCompleted >= sessionsPerRound {
                sessionsCompleted = 0
                currentSession = .longBreak
                totalTime = longBreakDuration * 60
            } else {
                currentSession = .shortBreak
                totalTime = shortBreakDuration * 60
            }
        case .shortBreak, .longBreak:
            currentSession = .focus
            totalTime = focusDuration * 60
        }
        timeRemaining = totalTime
    }

    private func resetTimer() {
        totalTime = focusDuration * 60
        timeRemaining = totalTime
    }

    private func saveSession(completed: Bool) {
        guard let repo = repository else { return }
        let session = FocusSession(
            taskID: activeTask?.id,
            durationMinutes: focusDuration,
            type: currentSession,
            wasCompleted: completed
        )
        try? repo.save(session)
    }

    // MARK: - Notifications

    private func scheduleBackgroundNotification() {
        let content = UNMutableNotificationContent()
        switch currentSession {
        case .focus:
            content.title = String(localized: "Focus finished")
            content.body  = String(localized: "Time for a break 🎉")
        case .shortBreak:
            content.title = String(localized: "Short Break finished")
            content.body  = String(localized: "Back to focus 🎯")
        case .longBreak:
            content.title = String(localized: "Long Break finished")
            content.body  = String(localized: "Back to focus 🎯")
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(timeRemaining),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "pomodoro.session",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelBackgroundNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["pomodoro.session"])
    }

    // MARK: - Haptics

    private func hapticSuccess() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }
}

// MARK: - SessionType

enum SessionType: String, Codable {
    case focus, shortBreak, longBreak
}

// MARK: - FocusSession SwiftData model

@Model
final class FocusSession {
    var id: UUID
    var taskID: UUID?
    var startedAt: Date
    var completedAt: Date?
    var durationMinutes: Int
    var typeRaw: String
    var wasCompleted: Bool

    var type: SessionType {
        get { SessionType(rawValue: typeRaw) ?? .focus }
        set { typeRaw = newValue.rawValue }
    }

    init(taskID: UUID? = nil, durationMinutes: Int, type: SessionType, wasCompleted: Bool) {
        self.id              = UUID()
        self.taskID          = taskID
        self.startedAt       = Date()
        self.durationMinutes = durationMinutes
        self.typeRaw         = type.rawValue
        self.wasCompleted    = wasCompleted
    }
}

// MARK: - Repository Protocol

protocol FocusSessionRepositoryProtocol {
    func save(_ session: FocusSession) throws
    func sessions(for date: Date) -> [FocusSession]
    func totalFocusTime(for date: Date) -> Int
}

// MARK: - Repository Implementation

final class FocusSessionRepository: FocusSessionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ session: FocusSession) throws {
        context.insert(session)
        try context.save()
    }

    func sessions(for date: Date) -> [FocusSession] {
        let start = Calendar.current.startOfDay(for: date)
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let pred  = #Predicate<FocusSession> {
            $0.startedAt >= start && $0.startedAt < end
        }
        return (try? context.fetch(FetchDescriptor(predicate: pred))) ?? []
    }

    func totalFocusTime(for date: Date) -> Int {
        sessions(for: date)
            .filter { $0.wasCompleted && $0.type == .focus }
            .reduce(0) { $0 + $1.durationMinutes * 60 }
    }
}
